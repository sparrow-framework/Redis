import IO
import Venice

public struct RedisError : Error, CustomStringConvertible {
    public let description: String
}

extension RedisError {
    static var unexpected: RedisError {
        return RedisError(description: "Unexpected redis error.")
    }
}

public final class Redis {
    public enum Reply {
        case status(String)
        case integer(Int64)
        case null
        case string(String)
        case array([Reply])
    }
    
    private let transport: TCPStream
    private let parser = RedisParser()
    private let buffer: UnsafeMutableRawBufferPointer
    
    public init(
        host: String,
        port: Int = 6379,
        bufferSize: Int = 4096,
        deadline: Deadline = 1.minute.fromNow()
    ) throws {
        self.transport = try TCPStream(host: host, port: port, deadline: deadline)
        self.buffer = UnsafeMutableRawBufferPointer.allocate(count: bufferSize)
        try transport.open(deadline: deadline)
    }
    
    deinit {
        buffer.deallocate()
    }
    
    public func send(
        _ command: String,
        deadline: Deadline = 1.minute.fromNow()
    ) throws -> Reply {
        while true {
            try transport.write(command, deadline: deadline)
            let read = try transport.read(buffer, deadline: deadline)
            
            guard let reply = try parser.parse(read) else {
                continue
            }
            
            return reply
        }
    }
}

extension Redis.Reply {
    public var isOK: Bool {
        guard case let .status(status) = self else {
            return false
        }
        
        return status == "OK"
    }
}

extension Redis {
    public func set(key: String, value: String) throws -> Reply {
        return try send("SET " + key + " \"" + value + "\"\r\n")
    }
    
    public func get(key: String) throws -> Reply {
        return try send("GET " + key + "\r\n")
    }
    
    public func transaction(
        watching watchedKeys: String...,
        discards: Bool = true,
        body: (Void) throws -> Void
    ) throws -> Reply {
        var reply: Reply
        
        if watchedKeys.count > 0 {
            reply = try send("WATCH \(watchedKeys.joined(separator: " "))\r\n")
            
            guard reply.isOK else {
                throw RedisError.unexpected
            }
        }
        
        reply = try send("MULTI\r\n")
        
        guard reply.isOK else {
            throw RedisError.unexpected
        }
        
        if discards {
            do {
                try body()
            } catch {
                return try send("DISCARD\r\n")
            }
        } else {
            try body()
        }
        
        return try send("EXEC\r\n")
    }
}
