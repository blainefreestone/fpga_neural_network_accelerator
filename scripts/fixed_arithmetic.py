import argparse
from decimal_to_fixed import decimal_to_fixed_point
from fixed_to_decimal import fixed_point_to_decimal

def fixed_point_add_hw(bin_a, bin_b, int_bits, frac_bits, signed=True):
    """
    Add two fixed-point binary numbers as it would happen in hardware.
    
    :param bin_a: First binary string (without decimal point)
    :param bin_b: Second binary string (without decimal point)
    :param int_bits: Number of integer bits
    :param frac_bits: Number of fractional bits
    :param signed: Whether numbers are signed
    :return: Result as a binary string
    """
    total_bits = int_bits + frac_bits
    
    # Convert binary strings to integers
    int_a = int(bin_a, 2)
    int_b = int(bin_b, 2)
    
    # Perform binary addition
    int_result = int_a + int_b
    
    # Handle overflow in a hardware-like way (truncate to total bits)
    int_result = int_result & ((1 << total_bits) - 1)
    
    # Convert back to binary string with fixed width
    binary_result = format(int_result, f'0{total_bits}b')
    
    return binary_result

def fixed_point_multiply_hw(bin_a, bin_b, int_bits, frac_bits, signed=True):
    """
    Multiply two fixed-point binary numbers as it would happen in hardware.
    
    :param bin_a: First binary string (without decimal point)
    :param bin_b: Second binary string (without decimal point)
    :param int_bits: Number of integer bits
    :param frac_bits: Number of fractional bits
    :param signed: Whether numbers are signed
    :return: Result as a binary string
    """
    total_bits = int_bits + frac_bits
    
    # Convert binary strings to integers
    int_a = int(bin_a, 2)
    int_b = int(bin_b, 2)
    
    # Handle signed multiplication if needed
    if signed:
        # Check if negative (MSB is 1)
        if bin_a[0] == '1':
            int_a = int_a - (1 << total_bits)
        if bin_b[0] == '1':
            int_b = int_b - (1 << total_bits)
    
    # Perform binary multiplication and adjust for fixed point
    full_result = int_a * int_b
    
    # Scale result back (divide by 2^frac_bits)
    scaled_result = full_result >> frac_bits
    
    # Truncate to fit in the original format
    masked_result = scaled_result & ((1 << total_bits) - 1)
    
    # Convert back to binary string with fixed width
    binary_result = format(masked_result, f'0{total_bits}b')
    
    return binary_result

def main():
    parser = argparse.ArgumentParser(description="Perform hardware-simulated fixed-point arithmetic operations.")
    parser.add_argument("operation", choices=["add", "multiply"], help="Arithmetic operation to perform")
    parser.add_argument("--value1", type=str, help="First binary value or decimal number if --decimal flag is used")
    parser.add_argument("--value2", type=str, help="Second binary value or decimal number if --decimal flag is used")
    parser.add_argument("--int_bits", type=int, help="Number of integer bits")
    parser.add_argument("--frac_bits", type=int, help="Number of fractional bits")
    parser.add_argument("--signed", action="store_true", help="Whether numbers are signed (default: True)")
    parser.add_argument("--decimal", action="store_true", help="Interpret input values as decimal numbers")
    
    args = parser.parse_args()
    
    try:
        total_bits = args.int_bits + args.frac_bits
        
        if args.decimal:
            # Convert decimal inputs to fixed-point
            val1_dec = float(args.value1)
            val2_dec = float(args.value2)
            
            bin1, actual1 = decimal_to_fixed_point(val1_dec, args.int_bits, args.frac_bits, args.signed)
            bin2, actual2 = decimal_to_fixed_point(val2_dec, args.int_bits, args.frac_bits, args.signed)
            
            # Remove decimal points
            bin1 = bin1.replace('.', '')
            bin2 = bin2.replace('.', '')
            
            # Calculate expected result using decimal math
            if args.operation == "add":
                exact_dec_result = val1_dec + val2_dec
                operation_name = "Addition"
            else:  # multiply
                exact_dec_result = val1_dec * val2_dec
                operation_name = "Multiplication"
                
            print(f"Decimal input 1: {val1_dec}")
            print(f"    ↪ Fixed-point representation: {bin1[:args.int_bits]}.{bin1[args.int_bits:]}")
            print(f"    ↪ Actual value after conversion: {actual1}")
            
            print(f"Decimal input 2: {val2_dec}")
            print(f"    ↪ Fixed-point representation: {bin2[:args.int_bits]}.{bin2[args.int_bits:]}")
            print(f"    ↪ Actual value after conversion: {actual2}")
            
        else:
            # Use binary inputs directly
            bin1 = args.value1
            bin2 = args.value2
            
            # Verify binary string lengths
            if len(bin1) != total_bits or len(bin2) != total_bits:
                raise ValueError(f"Binary strings must be exactly {total_bits} bits long")
            
            # Convert to decimal for display
            val1_dec = fixed_point_to_decimal(bin1, args.int_bits, args.frac_bits, args.signed)
            val2_dec = fixed_point_to_decimal(bin2, args.int_bits, args.frac_bits, args.signed)
            
            # Calculate expected result using decimal math
            if args.operation == "add":
                exact_dec_result = val1_dec + val2_dec
                operation_name = "Addition"
            else:  # multiply
                exact_dec_result = val1_dec * val2_dec
                operation_name = "Multiplication"
                
            print(f"Binary input 1: {bin1[:args.int_bits]}.{bin1[args.int_bits:]}")
            print(f"    ↪ Decimal value: {val1_dec}")
            
            print(f"Binary input 2: {bin2[:args.int_bits]}.{bin2[args.int_bits:]}")
            print(f"    ↪ Decimal value: {val2_dec}")
        
        # Show the mathematically exact result
        print(f"\nMathematically exact {args.operation} result: {exact_dec_result}")
        
        # Perform hardware-simulated fixed-point operation
        if args.operation == "add":
            result_bin = fixed_point_add_hw(bin1, bin2, args.int_bits, args.frac_bits, args.signed)
        else:  # multiply
            result_bin = fixed_point_multiply_hw(bin1, bin2, args.int_bits, args.frac_bits, args.signed)
        
        # Convert the fixed-point result back to decimal
        hw_result_dec = fixed_point_to_decimal(result_bin, args.int_bits, args.frac_bits, args.signed)
        
        # Format the result for display with the binary point
        result_with_point = f"{result_bin[:args.int_bits]}.{result_bin[args.int_bits:]}"
        
        print(f"\nHardware fixed-point {args.operation} result:")
        print(f"    ↪ Binary: {result_with_point}")
        print(f"    ↪ Decimal interpretation: {hw_result_dec}")
        
        # Show the difference
        print(f"\nDifference between exact and hardware result: {hw_result_dec - exact_dec_result}")
        
    except ValueError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")

if __name__ == "__main__":
    main()