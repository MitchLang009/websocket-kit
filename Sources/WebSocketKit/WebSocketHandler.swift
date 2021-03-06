import NIO
import NIOWebSocket

extension WebSocket {
    public static func client(
        on channel: Channel,
        onUpgrade: @escaping (WebSocket) -> ()
    ) -> EventLoopFuture<Void> {
        return self.handle(on: channel, as: .client, onUpgrade: onUpgrade)
    }

    public static func server(
        on channel: Channel,
        onUpgrade: @escaping (WebSocket) -> ()
    ) -> EventLoopFuture<Void> {
        return self.handle(on: channel, as: .server, onUpgrade: onUpgrade)
    }

    private static func handle(
        on channel: Channel,
        as type: PeerType,
        onUpgrade: @escaping (WebSocket) -> ()
    ) -> EventLoopFuture<Void> {
        let webSocket = WebSocket(channel: channel, type: type)
        return channel.pipeline.addHandler(WebSocketHandler(webSocket: webSocket)).map { _ in
            onUpgrade(webSocket)
        }
    }
}

private final class WebSocketHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame
    private var webSocket: WebSocket

    init(webSocket: WebSocket) {
        self.webSocket = webSocket
    }

    /// See `ChannelInboundHandler`.
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        self.webSocket.handle(incoming: frame)
    }
}
