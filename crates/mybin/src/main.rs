use mylib;

fn main() {
    let left = 10;
    let right = 32;
    println!(
        "Hello, world! {left} plus {right} is {}!",
        mylib::add(left, right)
    );
}
