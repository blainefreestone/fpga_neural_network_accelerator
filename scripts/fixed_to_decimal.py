import argparse

def fixed_point_to_decimal(binary_str, int_bits, frac_bits, signed):
    total_bits = int_bits + frac_bits
    
    if len(binary_str) != total_bits:
        raise ValueError(f"Binary string length ({len(binary_str)}) must match the total bit length ({total_bits}).")
    
    if signed and binary_str[0] == '1':
        # Convert to two's complement for signed numbers
        int_value = -((1 << total_bits) - int(binary_str, 2))
    else:
        int_value = int(binary_str, 2)
    
    return int_value / (1 << frac_bits)

def main():
    parser = argparse.ArgumentParser(description="Convert fixed-point binary to decimal.")
    parser.add_argument("value", type=str, help="Binary string to convert")
    parser.add_argument("int_bits", type=int, help="Number of integer bits")
    parser.add_argument("frac_bits", type=int, help="Number of fractional bits")
    parser.add_argument("--signed", action="store_true", help="Specify if the number is signed")
    
    args = parser.parse_args()
    
    try:
        result = fixed_point_to_decimal(args.value, args.int_bits, args.frac_bits, args.signed)
        print(f"Decimal value: {result}")
    except ValueError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
