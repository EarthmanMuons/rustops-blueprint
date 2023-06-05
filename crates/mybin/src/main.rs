#![deny(clippy::all)]
#![warn(clippy::nursery, clippy::pedantic)]

use mylib::{add, shuffle_array};

fn main() {
    let left = 10;
    let right = 32;
    println!("Hello, world! {left} plus {right} is {}!", add(left, right));

    let mut nums = [1, 2, 3, 4, 5];
    println!("Unshuffled: {nums:?}");
    shuffle_array(&mut nums);
    println!("Shuffled:   {nums:?}");

    println!("mybin {}", get_version());
}

fn get_version() -> &'static str {
    option_env!("MYBIN_VERSION").unwrap_or(env!("CARGO_PKG_VERSION"))
}
