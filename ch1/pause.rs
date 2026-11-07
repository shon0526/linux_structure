use std::thread;
use std::time::Duration;

fn main() {
    let second = Duration::from_secs(10);
    let sleep = thread::sleep(second);
    return;
}
