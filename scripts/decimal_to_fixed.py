import argparse

def decimal_to_fixed_point(value, int_bits, frac_bits, signed=True):
    """
    Converts a decimal number into a fixed-point binary representation.
    
    :param value: The decimal number to convert.
    :param int_bits: The number of bits for the integer part.
    :param frac_bits: The number of bits for the fractional part.
    :param signed: Whether to include a sign bit (default: True).
    :return: The fixed-point binary string representation and the precision error.
    """
    
    # Determine the range limits
    if signed:
        max_value = (2 ** (int_bits - 1)) - (1 / (2 ** frac_bits))
        min_value = -(2 ** (int_bits - 1))
    else:
        max_value = (2 ** int_bits) - (1 / (2 ** frac_bits))
        min_value = 0
    
    # Check if value is within range
    if value < min_value or value > max_value:
        raise ValueError(f"Value {value} out of range [{min_value}, {max_value}]")
    
    # Scale the value by 2^frac_bits to shift decimal part into integer range
    scaled_value = round(value * (2 ** frac_bits))
    
    # Calculate total bits
    total_bits = int_bits + frac_bits
    
    # Handle two's complement for negative values if signed
    if signed and value < 0:
        scaled_value = (1 << total_bits) + scaled_value  # Apply two's complement
    
    # Convert to binary string with fixed width
    binary_str = format(scaled_value, f'0{total_bits}b')
    
    # Insert the binary point at the correct position
    fixed_point_str = binary_str[:int_bits] + '.' + binary_str[int_bits:]
    
    # Compute the actual value represented by the fixed-point binary string
    actual_value = scaled_value / (2 ** frac_bits)
    
    return fixed_point_str, actual_value

def main():
    parser = argparse.ArgumentParser(description="Convert a decimal number to fixed-point binary representation.")
    parser.add_argument("value", type=float, help="Decimal number to convert")
    parser.add_argument("int_bits", type=int, help="Number of bits for the integer part")
    parser.add_argument("frac_bits", type=int, help="Number of bits for the fractional part")
    parser.add_argument("--signed", action="store_true", help="Include a sign bit (default: False)")
    
    args = parser.parse_args()
    
    try:
        binary_repr, actual_value = decimal_to_fixed_point(args.value, args.int_bits, args.frac_bits, args.signed)
        print(f"Fixed-point representation: {binary_repr}")
        print(f"Actual value: {actual_value}")
    except ValueError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
