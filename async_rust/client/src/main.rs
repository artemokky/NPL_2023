use std::io::{self, ErrorKind, Read, Write};
use std::net::TcpStream;
use std::sync::mpsc::{self, TryRecvError};
use std::thread;
use std::time::Duration;

const LOCAL_ADDRESS: &str = "127.0.0.1:6000";
const MESSAGE_MAX_SIZE: usize = 128;
const LOOP_AWAIT: u64 = 100;

fn main() {
    let mut client = TcpStream::connect(LOCAL_ADDRESS).expect("Fail in stream connection");
    client.set_nonblocking(true).expect("Fail in non-blocking");

    let (sender, receiver) = mpsc::channel::<String>();

    thread::spawn(move || loop {
        let mut buffer = vec![0; MESSAGE_MAX_SIZE];
        match client.read_exact(&mut buffer) {
            Ok(_) => {
                let message = String::from_utf8(
                    buffer.into_iter()
                        .take_while(|&sym| sym != 0)
                        .collect())
                    .expect("Fail message encoding");
                println!("{:?}", message);
            }
            Err(ref error) if error.kind() == ErrorKind::WouldBlock => (),
            Err(_) => {
                println!("Lost connection with server");
                break;
            }
        }

        match receiver.try_recv() {
            Ok(message) => {
                let mut buffer = message.clone().into_bytes();
                buffer.resize(MESSAGE_MAX_SIZE, 0);
                client.write_all(&buffer).expect("Fail in socket writing");
                println!("Success! Message sent");
            }
            Err(TryRecvError::Empty) => (),
            Err(TryRecvError::Disconnected) => break
        }
        thread::sleep(Duration::from_millis(LOOP_AWAIT));
    });

    println!("Enter Message:");
    loop {
        let mut buffer = String::new();
        io::stdin().read_line(&mut buffer).expect("Fail in stdin reading");
        let message = buffer.trim().to_string();

        if message == ":q" || sender.send(message).is_err() {
            break;
        }
    }
    println!("Client work ended");
}
