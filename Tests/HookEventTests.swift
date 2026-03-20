import XCTest
@testable import ccpulse

final class HookEventTests: XCTestCase {

    func testDecodeFullEvent() throws {
        let json = """
        {
            "session_id": "abc-123",
            "hook_event_name": "UserPromptSubmit",
            "cwd": "/Users/test/project",
            "tool_name": "Read",
            "notification_type": "info",
            "prompt": "fix the bug"
        }
        """.data(using: .utf8)!

        let event = try JSONDecoder().decode(HookEvent.self, from: json)
        XCTAssertEqual(event.sessionId, "abc-123")
        XCTAssertEqual(event.hookEventName, "UserPromptSubmit")
        XCTAssertEqual(event.cwd, "/Users/test/project")
        XCTAssertEqual(event.toolName, "Read")
        XCTAssertEqual(event.notificationType, "info")
        XCTAssertEqual(event.prompt, "fix the bug")
    }

    func testDecodeMinimalEvent() throws {
        let json = """
        {
            "session_id": "abc-123",
            "hook_event_name": "Stop"
        }
        """.data(using: .utf8)!

        let event = try JSONDecoder().decode(HookEvent.self, from: json)
        XCTAssertEqual(event.sessionId, "abc-123")
        XCTAssertEqual(event.hookEventName, "Stop")
        XCTAssertNil(event.cwd)
        XCTAssertNil(event.toolName)
        XCTAssertNil(event.notificationType)
        XCTAssertNil(event.prompt)
    }
}
