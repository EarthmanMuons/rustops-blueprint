use mylib::shuffle_array;

#[test]
fn test_shuffle_array() {
    let mut nums = [1, 2, 3, 4, 5];
    let original = nums;
    shuffle_array(&mut nums);

    assert_eq!(nums.len(), original.len());
    for num in &original {
        assert!(nums.contains(num));
    }
}
