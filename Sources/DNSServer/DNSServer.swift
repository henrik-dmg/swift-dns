// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
//import NIO
import Network

@main
struct DNSServer: ParsableCommand {

    var isReady = false

    mutating func run() throws {
        let port = NWEndpoint.Port(rawValue: 9999)!
        let params = NWParameters.udp
        // This is for UDP so allowFastOpen is generally wanted
        params.allowFastOpen = true
        let listener = try? NWListener(using: params, on: port)
        listener?.stateUpdateHandler = { update in
            switch update {
            case .ready:
                // This is Part 1 of the UDP Listener
//                self.isReady = true
                print("Listener connected to port \(port)")
            case .failed, .cancelled:
                // Announce we are no longer able to listen
//                self.isReady = false
                print("Listener disconnected from port \(port)")
            default:
                print("Listener connecting to port \(port)…")
            }
        }
        listener?.newConnectionHandler = { connection in
            print("Listener receiving new message")
            // This is Part 2 of the UDP Listener, handle an incoming "connection"
//            self.createConnection(connection: connection)
        }
        listener?.start(queue: .main)
    }
}


//private final class EchoHandler: ChannelInboundHandler {
//    typealias InboundIn = AddressedEnvelope<ByteBuffer>
//
//    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        let addressedEnvelope = self.unwrapInboundIn(data)
//        print("Recieved data from \(addressedEnvelope.remoteAddress)")
//        context.write(data, promise: nil)
//    }
//
//    public func channelReadComplete(context: ChannelHandlerContext) {
//        context.flush()
//    }
//
//    public func errorCaught(context: ChannelHandlerContext, error: Error) {
//        print("error :", error)
//
//        context.close(promise: nil)
//    }
//}
//
//let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//
//// Using DatagramBootstrap turns out to be the only significant change between TCP and UDP in this case
//let bootstrap = DatagramBootstrap(group: group)
//    .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
//    .channelInitializer { channel in
//        channel.pipeline.addHandler(EchoHandler())
//    }
//defer {
//    try! group.syncShutdownGracefully()
//}
//
//let defaultPort = 9999
//
//let arguments = CommandLine.arguments
//let port = arguments.dropFirst().compactMap {Int($0)}.first ?? defaultPort
//
//let channel = try! bootstrap.bind(host: "127.0.0.1", port: port).wait()
//
//print("Channel accepting connections on \(channel.localAddress!)")
//
//try channel.closeFuture.wait()
//
//print("Channel closed")
