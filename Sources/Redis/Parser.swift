import CHiredis

final class RedisParser {
    private let reader: UnsafeMutablePointer<redisReader>!
    
    init() {
        reader = redisReaderCreate()
    }
    
    deinit {
        redisReaderFree(reader)
    }
    
    func parse(_ buffer: UnsafeRawBufferPointer) throws -> Redis.Reply? {
        var result = redisReaderFeed(
            reader,
            buffer.baseAddress?.assumingMemoryBound(to: Int8.self),
            buffer.count
        )
        
        switch result {
        case REDIS_OK:
            break
        case REDIS_ERR:
            throw try reader.pointee.error()
        default:
            throw RedisError.unexpected
        }
        
        var reply: UnsafeMutableRawPointer? = nil
        
        return try withUnsafeMutablePointer(to: &reply) {
            result = redisReaderGetReply(reader, $0)
            
            defer {
                freeReplyObject(reply)
            }
            
            switch result {
            case REDIS_OK:
                break
            case REDIS_ERR:
                throw try reader.pointee.error()
            default:
                throw RedisError.unexpected
            }
            
            guard let reply = reply else {
                return nil
            }
            
            return try convert(reply: reply)
        }
    }
    
    private func convert(reply: UnsafeMutableRawPointer) throws -> Redis.Reply {
        let reply = reply.assumingMemoryBound(to: redisReply.self).pointee
        
        switch reply.type {
        case REDIS_REPLY_STATUS:
            return convertStatus(cString: reply.str, count: Int(reply.len))
        case REDIS_REPLY_ERROR:
            throw convertError(cString: reply.str, count: Int(reply.len))
        case REDIS_REPLY_INTEGER:
            return .integer(reply.integer)
        case REDIS_REPLY_NIL:
            return .null
        case REDIS_REPLY_STRING:
            return convertString(cString: reply.str, count: Int(reply.len))
        case REDIS_REPLY_ARRAY:
            return try convertArray(elements: reply.element, count: reply.elements)
        default:
            throw RedisError.unexpected
        }
    }
    
    private func convertStatus(cString: UnsafeMutablePointer<Int8>, count: Int) -> Redis.Reply {
        let status = convert(cString: cString, count: count)
        return .status(status)
    }
    
    private func convertError(cString: UnsafeMutablePointer<Int8>, count: Int) -> RedisError {
        let error = convert(cString: cString, count: count)
        return RedisError(description: error)
    }
    
    private func convertString(cString: UnsafeMutablePointer<Int8>, count: Int) -> Redis.Reply {
        let string = convert(cString: cString, count: count)
        return .string(string)
    }
    
    private func convertArray(
        elements: UnsafeMutablePointer<UnsafeMutablePointer<redisReply>?>,
        count: Int
    ) throws -> Redis.Reply {
        var array: [Redis.Reply] = []
        
        for index in 0 ..< count {
            guard let element = elements[index] else {
                continue
            }
            
            let reply = try convert(reply: UnsafeMutableRawPointer(element))
            array.append(reply)
        }
        
        return .array(array)
    }
    
    private func convert(cString: UnsafeMutablePointer<Int8>, count: Int) -> String {
        let buffer = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(cString), count: count)
        var cString: [UInt8] = []
        cString.append(contentsOf: buffer)
        cString.append(0)
        return String(cString: cString)
    }
}

extension redisReader {
    private func check(_ byte: Int8, cString: inout [Int8]) throws {
        cString.append(byte)
        
        if byte == 0 {
            let string = String(cString: cString)
            throw RedisError(description: string)
        }
    }
    
    fileprivate func error() throws -> RedisError {
        var cString: [Int8] = []
        
        try check(errstr.0, cString: &cString)
        try check(errstr.1, cString: &cString)
        try check(errstr.2, cString: &cString)
        try check(errstr.3, cString: &cString)
        try check(errstr.4, cString: &cString)
        try check(errstr.5, cString: &cString)
        try check(errstr.6, cString: &cString)
        try check(errstr.7, cString: &cString)
        try check(errstr.8, cString: &cString)
        try check(errstr.9, cString: &cString)
        
        try check(errstr.10, cString: &cString)
        try check(errstr.11, cString: &cString)
        try check(errstr.12, cString: &cString)
        try check(errstr.13, cString: &cString)
        try check(errstr.14, cString: &cString)
        try check(errstr.15, cString: &cString)
        try check(errstr.16, cString: &cString)
        try check(errstr.17, cString: &cString)
        try check(errstr.18, cString: &cString)
        try check(errstr.19, cString: &cString)
        
        try check(errstr.20, cString: &cString)
        try check(errstr.21, cString: &cString)
        try check(errstr.22, cString: &cString)
        try check(errstr.23, cString: &cString)
        try check(errstr.24, cString: &cString)
        try check(errstr.25, cString: &cString)
        try check(errstr.26, cString: &cString)
        try check(errstr.27, cString: &cString)
        try check(errstr.28, cString: &cString)
        try check(errstr.29, cString: &cString)
        
        try check(errstr.30, cString: &cString)
        try check(errstr.31, cString: &cString)
        try check(errstr.32, cString: &cString)
        try check(errstr.33, cString: &cString)
        try check(errstr.34, cString: &cString)
        try check(errstr.35, cString: &cString)
        try check(errstr.36, cString: &cString)
        try check(errstr.37, cString: &cString)
        try check(errstr.38, cString: &cString)
        try check(errstr.39, cString: &cString)
        
        try check(errstr.40, cString: &cString)
        try check(errstr.41, cString: &cString)
        try check(errstr.42, cString: &cString)
        try check(errstr.43, cString: &cString)
        try check(errstr.44, cString: &cString)
        try check(errstr.45, cString: &cString)
        try check(errstr.46, cString: &cString)
        try check(errstr.47, cString: &cString)
        try check(errstr.48, cString: &cString)
        try check(errstr.49, cString: &cString)
        
        try check(errstr.50, cString: &cString)
        try check(errstr.51, cString: &cString)
        try check(errstr.52, cString: &cString)
        try check(errstr.53, cString: &cString)
        try check(errstr.54, cString: &cString)
        try check(errstr.55, cString: &cString)
        try check(errstr.56, cString: &cString)
        try check(errstr.57, cString: &cString)
        try check(errstr.58, cString: &cString)
        try check(errstr.59, cString: &cString)
        
        try check(errstr.60, cString: &cString)
        try check(errstr.61, cString: &cString)
        try check(errstr.62, cString: &cString)
        try check(errstr.63, cString: &cString)
        try check(errstr.64, cString: &cString)
        try check(errstr.65, cString: &cString)
        try check(errstr.66, cString: &cString)
        try check(errstr.67, cString: &cString)
        try check(errstr.68, cString: &cString)
        try check(errstr.69, cString: &cString)
        
        try check(errstr.70, cString: &cString)
        try check(errstr.71, cString: &cString)
        try check(errstr.72, cString: &cString)
        try check(errstr.73, cString: &cString)
        try check(errstr.74, cString: &cString)
        try check(errstr.75, cString: &cString)
        try check(errstr.76, cString: &cString)
        try check(errstr.77, cString: &cString)
        try check(errstr.78, cString: &cString)
        try check(errstr.79, cString: &cString)
        
        try check(errstr.80, cString: &cString)
        try check(errstr.81, cString: &cString)
        try check(errstr.82, cString: &cString)
        try check(errstr.83, cString: &cString)
        try check(errstr.84, cString: &cString)
        try check(errstr.85, cString: &cString)
        try check(errstr.86, cString: &cString)
        try check(errstr.87, cString: &cString)
        try check(errstr.88, cString: &cString)
        try check(errstr.89, cString: &cString)
        
        try check(errstr.90, cString: &cString)
        try check(errstr.91, cString: &cString)
        try check(errstr.92, cString: &cString)
        try check(errstr.93, cString: &cString)
        try check(errstr.94, cString: &cString)
        try check(errstr.95, cString: &cString)
        try check(errstr.96, cString: &cString)
        try check(errstr.97, cString: &cString)
        try check(errstr.98, cString: &cString)
        try check(errstr.99, cString: &cString)
        
        try check(errstr.100, cString: &cString)
        try check(errstr.101, cString: &cString)
        try check(errstr.102, cString: &cString)
        try check(errstr.103, cString: &cString)
        try check(errstr.104, cString: &cString)
        try check(errstr.105, cString: &cString)
        try check(errstr.106, cString: &cString)
        try check(errstr.107, cString: &cString)
        try check(errstr.108, cString: &cString)
        try check(errstr.109, cString: &cString)
        
        try check(errstr.110, cString: &cString)
        try check(errstr.111, cString: &cString)
        try check(errstr.112, cString: &cString)
        try check(errstr.113, cString: &cString)
        try check(errstr.114, cString: &cString)
        try check(errstr.115, cString: &cString)
        try check(errstr.116, cString: &cString)
        try check(errstr.117, cString: &cString)
        try check(errstr.118, cString: &cString)
        try check(errstr.119, cString: &cString)
        
        try check(errstr.120, cString: &cString)
        try check(errstr.121, cString: &cString)
        try check(errstr.122, cString: &cString)
        try check(errstr.123, cString: &cString)
        try check(errstr.124, cString: &cString)
        try check(errstr.125, cString: &cString)
        try check(errstr.126, cString: &cString)
        try check(errstr.127, cString: &cString)
        
        cString.append(0)
        let string = String(cString: cString)
        throw RedisError(description: string)
    }
}
