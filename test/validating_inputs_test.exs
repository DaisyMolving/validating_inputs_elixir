defmodule ValidatingInputsTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ValidatingInputs

  test "prints out each request" do
    assert capture_io(fn ->
      ValidatingInputs.print_input_request(:first_name)
    end) =~ "first name"
    assert capture_io(fn ->
      ValidatingInputs.print_input_request(:last_name)
    end) =~ "last name"
    assert capture_io(fn ->
      ValidatingInputs.print_input_request(:zip_code)
    end) =~ "zip code"
    assert capture_io(fn ->
      ValidatingInputs.print_input_request(:employee_id)
    end) =~ "employee id"
  end

  test "a first name or last name must be at least 2 letters long" do 
    assert capture_io("retry", fn ->
	ValidatingInputs.validate_type("D", :first_name) 
    end) =~ "first name must be at least two characters long" 
    assert ValidatingInputs.validate_type("Molving", :last_name) == "Molving"
  end 

  test "a zip code must be completely numerical" do
    assert capture_io("12345", fn ->
       ValidatingInputs.validate_type("ABC4E", :zip_code) 
    end) =~ "zip code must be numerical"
    assert ValidatingInputs.validate_type("12345", :zip_code) == "12345"
  end

  test "an employee id must start with two letters, then a hyphen, then four numbers" do
    assert capture_io("ZZ-7890", fn ->
      ValidatingInputs.validate_type("AA1234", :employee_id)
    end) =~ "employee id must have two letters followed by a hyphen, then four numbers"
    assert ValidatingInputs.validate_type("AA-1234", :employee_id) == "AA-1234"
  end

  test "invalid_empty message is printed when field is empty" do
    assert capture_io("retry", fn -> ValidatingInputs.validate_not_empty("", :first_name) 
    end) == "That is an invalid input, first_name cannot be empty. Please try again: "
  end 

  test "invalid_empty message takes an input" do
    input = "retry"
    assert capture_io([input: input, capture_prompt: false], fn ->
      IO.write(ValidatingInputs.retry_for_empty_field(:first_name))
    end) == "retry"
  end 

  test "prints no errors message" do
    assert capture_io(fn ->
      ValidatingInputs.print_no_found_error_message
    end) =~ "no errors found"
  end

  test "runs through every category to validate inputs" do
    assert capture_io("daisy\nmolving\n12345\nGG-6735", fn ->
      ValidatingInputs.run_validation_checks
    end) =~ "no errors found"
  end
end
