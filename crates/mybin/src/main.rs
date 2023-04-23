use rand::seq::SliceRandom;
use rand::thread_rng;

fn main() {
    let left = 10;
    let right = 32;
    println!(
        "Hello, world! {left} plus {right} is {}!",
        mylib::add(left, right)
    );

    let mut rng = thread_rng();
    let mut nums = [1, 2, 3, 4, 5];
    println!("Unshuffled: {:?}", nums);
    nums.shuffle(&mut rng);
    println!("Shuffled:   {:?}", nums);
}
