import Foundation
import Network

class HookServer {
    private var listener: NWListener?
    private let onEvent: (HookEvent) -> Void
    private(set) var port: UInt16 = 19280

    init(onEvent: @escaping (HookEvent) -> Void) {
        self.onEvent = onEvent
    }

    func start() throws {
        // Check if another ccani instance is already running
        if let existingPort = readExistingPortFile(), isPortResponding(existingPort) {
            throw ServerError.anotherInstanceRunning(port: existingPort)
        }

        for candidatePort in UInt16(19280)...UInt16(19289) {
            do {
                let nwPort = NWEndpoint.Port(rawValue: candidatePort)!
                let params = NWParameters.tcp
                let listener = try NWListener(using: params, on: nwPort)
                self.listener = listener
                self.port = candidatePort
                writePortFile()

                listener.newConnectionHandler = { [weak self] conn in
                    self?.handleConnection(conn)
                }
                listener.stateUpdateHandler = { state in
                    if case .failed(let err) = state {
                        print("Server failed: \(err)")
                    }
                }
                listener.start(queue: .global(qos: .userInitiated))
                print("ccani server listening on port \(candidatePort)")
                return
            } catch {
                continue
            }
        }
        throw ServerError.noAvailablePort
    }

    func stop() {
        listener?.cancel()
        removePortFile()
    }

    // MARK: - Single Instance Detection

    private func readExistingPortFile() -> UInt16? {
        let file = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".ccani/port")
        guard let content = try? String(contentsOf: file, encoding: .utf8),
              let port = UInt16(content.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return port
    }

    private func isPortResponding(_ port: UInt16) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var responding = false

        let connection = NWConnection(host: "127.0.0.1", port: NWEndpoint.Port(rawValue: port)!, using: .tcp)
        connection.stateUpdateHandler = { state in
            if case .ready = state {
                responding = true
                semaphore.signal()
            } else if case .failed = state {
                semaphore.signal()
            }
        }
        connection.start(queue: .global())
        _ = semaphore.wait(timeout: .now() + 1.0)
        connection.cancel()
        return responding
    }

    // MARK: - Connection Handling

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .userInitiated))
        receiveData(from: connection, accumulated: Data())
    }

    private func receiveData(from connection: NWConnection, accumulated: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            var buffer = accumulated
            if let data = data { buffer.append(data) }

            if isComplete || error != nil {
                self?.processRequest(buffer, connection: connection)
            } else {
                self?.receiveData(from: connection, accumulated: buffer)
            }
        }
    }

    private func processRequest(_ data: Data, connection: NWConnection) {
        let response: String
        if let bodyRange = data.range(of: Data("\r\n\r\n".utf8)) {
            let body = data[bodyRange.upperBound...]
            if let event = try? JSONDecoder().decode(HookEvent.self, from: body) {
                DispatchQueue.main.async { self.onEvent(event) }
                response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\n{}"
            } else {
                response = "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n"
            }
        } else {
            response = "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n"
        }

        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    // MARK: - Port File

    private func writePortFile() {
        let dir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ccani")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("port")
        try? "\(port)".write(to: file, atomically: true, encoding: .utf8)
    }

    private func removePortFile() {
        let file = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".ccani/port")
        try? FileManager.default.removeItem(at: file)
    }

    enum ServerError: Error, LocalizedError {
        case noAvailablePort
        case anotherInstanceRunning(port: UInt16)

        var errorDescription: String? {
            switch self {
            case .noAvailablePort:
                return "No available port in range 19280-19289"
            case .anotherInstanceRunning(let port):
                return "Another ccani instance is already running on port \(port)"
            }
        }
    }
}
