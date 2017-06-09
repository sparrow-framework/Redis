import XCTest
@testable import Redis

class RedisTests : XCTestCase {
    func testPing() throws {
//        let redis = try Redis(host: "127.0.0.1")
//        let reply = try redis.send("PING\r\n")
//        
//        guard case let .status(status) = reply else {
//            return XCTFail()
//        }
//        
//        XCTAssertEqual(status, "PONG")
    }

    static var allTests = [
        ("testPing", testPing),
    ]
}
