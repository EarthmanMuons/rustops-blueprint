#![deny(clippy::all)]
#![warn(clippy::nursery, clippy::pedantic)]

use rand::seq::SliceRandom;

#[must_use]
pub const fn add(left: usize, right: usize) -> usize {
    left + right
}

pub fn shuffle_array(nums: &mut [i32]) {
    let mut rng = rand::thread_rng();
    nums.shuffle(&mut rng);
}

// Example fib functions for benchmarking.

// #[inline]
// #[must_use]
// pub fn fibonacci(n: u64) -> u64 {
//     match n {
//         0 => 0,
//         1 => 1,
//         n => fibonacci(n - 1) + fibonacci(n - 2),
//     }
// }

#[inline]
#[must_use]
pub fn fibonacci(n: u64) -> u64 {
    if n == 0 {
        return 0;
    }

    let mut a = 0;
    let mut b = 1;

    for _ in 1..n {
        let c = a + b;
        a = b;
        b = c;
    }
    b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(10, 32), 42);
    }

    #[test]
    fn test_fibonacci() {
        assert_eq!(fibonacci(20), 6765);
    }
}
