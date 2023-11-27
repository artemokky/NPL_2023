use std::io::{ErrorKind, Read, Write};
use std::net::TcpListener;
use std::ops::Add;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

const LOCAL_ADDRESS: &str = "127.0.0.1:6000";
const MESSAGE_MAX_SIZE: usize = 128;
const LOOP_AWAIT: u64 = 100;

fn main() {
    let server = TcpListener::bind(LOCAL_ADDRESS).expect("Fail bind listener");
    server.set_nonblocking(true).expect("Fail set nonblocking");

    let mut clients = vec![];
    let (sender, receiver) = mpsc::channel::<String>();

    loop {
        if let Ok((mut socket, address)) = server.accept() {
            println!("Client {} connected", address);

            let sender = sender.clone();
            clients.push(socket
                .try_clone()
                .expect("Fail clone client"));

            thread::spawn(move || loop {
                let mut buffer = vec![0; MESSAGE_MAX_SIZE];

                match socket.read_exact(&mut buffer) {
                    Ok(_) => {
                        let message = String::from_utf8(
                            buffer.into_iter()
                                .take_while(|&sym| sym != 0)
                                .collect())
                            .expect("Fail message encoding");

                        println!("Client <{}>: {:?}", address, message);

                        sender.send(address.to_string().add(": ").add(&*message))
                            .expect("Fail send message to receiver");
                    }
                    Err(ref error) if error.kind() == ErrorKind::WouldBlock => (),
                    Err(_) => {
                        println!("End connection with: <{}>", address);
                        break;
                    }
                }
                thread::sleep(Duration::from_millis(LOOP_AWAIT));
            });
        }

        if let Ok(message) = receiver.try_recv() {
            clients = clients
                .into_iter()
                .filter_map(|mut client|
                    {
                        let mut buffer = message.clone().into_bytes();
                        buffer.resize(MESSAGE_MAX_SIZE, 0);

                        client
                            .write_all(&buffer)
                            .map(|_| client)
                            .ok()
                    })
                .collect::<Vec<_>>();
        }
        thread::sleep(Duration::from_millis(LOOP_AWAIT));
    }
}
