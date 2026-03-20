import XCTest
@testable import ccpulse

final class SessionTests: XCTestCase {

    private func makeEvent(
        sessionId: String = "sess-1",
        name: String,
        cwd: String? = nil,
        toolName: String? = nil,
        prompt: String? = nil
    ) -> HookEvent {
        let json: [String: Any?] = [
            "session_id": sessionId,
            "hook_event_name": name,
            "cwd": cwd,
            "tool_name": toolName,
            "prompt": prompt
        ]
        let data = try! JSONSerialization.data(withJSONObject: json.compactMapValues { $0 })
        return try! JSONDecoder().decode(HookEvent.self, from: data)
    }

    // MARK: - State transitions

    func testInitialState() {
        let session = Session(id: "s1")
        XCTAssertEqual(session.state, .idle)
        XCTAssertFalse(session.isActive)
    }

    func testSessionStartSetsIdle() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "UserPromptSubmit"))
        XCTAssertEqual(session.state, .working)

        session.handleEvent(makeEvent(name: "SessionStart", cwd: "/tmp"))
        XCTAssertEqual(session.state, .idle)
        XCTAssertEqual(session.cwd, "/tmp")
    }

    func testUserPromptSubmitSetsWorking() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "UserPromptSubmit", prompt: "hello"))
        XCTAssertEqual(session.state, .working)
        XCTAssertTrue(session.isActive)
        XCTAssertEqual(session.lastPrompt, "hello")
    }

    func testToolUseSetsWorking() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "PreToolUse", toolName: "Bash"))
        XCTAssertEqual(session.state, .working)
        XCTAssertEqual(session.lastToolName, "Bash")
    }

    func testPostToolUseUpdatesToolName() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "PostToolUse", toolName: "Read"))
        XCTAssertEqual(session.lastToolName, "Read")
    }

    func testPermissionRequestSetsWaitingForUser() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "PermissionRequest"))
        XCTAssertEqual(session.state, .waitingForUser)
        XCTAssertTrue(session.isActive)
    }

    func testStopSetsIdle() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "UserPromptSubmit"))
        XCTAssertEqual(session.state, .working)

        session.handleEvent(makeEvent(name: "Stop"))
        XCTAssertEqual(session.state, .idle)
        XCTAssertFalse(session.isActive)
    }

    func testUnknownEventDoesNotChangeState() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "SomeUnknownEvent"))
        XCTAssertEqual(session.state, .idle)
    }

    // MARK: - Prompt tracking

    func testPromptUpdatedOnUserPromptSubmit() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "UserPromptSubmit", prompt: "first"))
        XCTAssertEqual(session.lastPrompt, "first")

        session.handleEvent(makeEvent(name: "UserPromptSubmit", prompt: "second"))
        XCTAssertEqual(session.lastPrompt, "second")
    }

    func testPromptNotClearedByOtherEvents() {
        let session = Session(id: "s1")
        session.handleEvent(makeEvent(name: "UserPromptSubmit", prompt: "keep me"))
        session.handleEvent(makeEvent(name: "PreToolUse", toolName: "Bash"))
        session.handleEvent(makeEvent(name: "Stop"))
        XCTAssertEqual(session.lastPrompt, "keep me")
    }

    // MARK: - projectName

    func testProjectNameFromCwd() {
        let session = Session(id: "s1", cwd: "/Users/test/my-project")
        XCTAssertEqual(session.projectName, "my-project")
    }

    func testProjectNameFallsBackToIdPrefix() {
        let session = Session(id: "abcdefghij")
        XCTAssertEqual(session.projectName, "abcdefgh")
    }

    // MARK: - formattedTime

    func testFormattedTimeMinutesSeconds() {
        let session = Session(id: "s1")
        // formattedTime uses elapsed from startTime, so we just check format
        let formatted = session.formattedTime
        XCTAssertTrue(formatted.contains(":"))
        // Should be MM:SS format (no hours for fresh session)
        XCTAssertEqual(formatted.count, 5) // "00:00"
    }
}
