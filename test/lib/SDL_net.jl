using Test

@testset "SDL_net" begin
    @test SDLNet_Init() == 0  # Ensure SDL_net initializes successfully

    # Set up server
    server_ip = Ref(LibSDL2.IPaddress(0, 0))
    @test SDLNet_ResolveHost(server_ip, C_NULL, 12345) == 0  # Check if resolving the host succeeds

    server_socket = SDLNet_TCP_Open(server_ip)
    @test server_socket != C_NULL  # Verify that server socket is successfully opened

    @debug("Server is running on port 12345...")

    # Set up client
    client_ip = Ref(LibSDL2.IPaddress(0, 0))
    @test SDLNet_ResolveHost(client_ip, pointer("127.0.0.1"), 12345) == 0  # Ensure client resolves host

    client_socket = SDLNet_TCP_Open(client_ip)
    @test client_socket != C_NULL  # Verify that client socket is successfully opened

    @debug("Client connected to server.")

    # Accept client connection on server side
    server_client_socket = SDLNet_TCP_Accept(server_socket)
    @test server_client_socket != C_NULL  # Ensure server accepts the connection

    @debug("Server accepted client connection.")

    # Send message from client to server
    message = "Hello, server!"
    message_ptr = pointer(message)
    bytes_sent = SDLNet_TCP_Send(client_socket, message_ptr, sizeof(message))
    @test bytes_sent > 0  # Ensure message is sent successfully

    @debug("Client sent message: ", message)

    # Receive message on server side
    buffer = Vector{UInt8}(undef, 256)
    bytes_received = SDLNet_TCP_Recv(server_client_socket, pointer(buffer), 256)
    @test bytes_received > 0  # Ensure data is received

    if bytes_received > 0
        received_message = unsafe_string(pointer(buffer))
        @debug("Server received message: ", received_message)
        @test received_message[1:bytes_received] == message  # Check if message matches
    else
        @debug("No message received.")
    end

    # Cleanup
    SDLNet_TCP_Close(client_socket)
    SDLNet_TCP_Close(server_client_socket)
    SDLNet_TCP_Close(server_socket)

    @test SDLNet_Quit() === nothing  # Verify SDLNet_Quit() executes without errors
end
