defmodule ValidatingInputsTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ValidatingInputs

  test "prints out each request" do
    func = &ValidatingInputs.print_input_request/1
    result = capture_output(func, :first_name)
    assert result =~ "Please enter your"
  end

  test "a first name or last name must be at least 2 letters long" do 
    func = &ValidatingInputs.validate_type/2
    result = capture_invalid_message(func, "D", "retry", :first_name)
    assert result =~ "first name must be at least two characters long"
  end 

  test "a zip code must be completely numerical" do
    func = &ValidatingInputs.validate_type/2
    result = capture_invalid_message(func, "ABC4E", "12345", :zip_code)
    assert result =~ "zip code must be numerical"
  end

  test "an employee id must start with two letters, then a hyphen, then four numbers" do
    func = &ValidatingInputs.validate_type/2
    result = capture_invalid_message(func, "AA1234", "ZZ-7890", :employee_id)
    assert result =~ "employee id must have two letters followed by a hyphen, then four numbers"
  end

  test "retry_for_empty_field message is printed when field is empty" do
    func = &ValidatingInputs.validate_not_empty/2
    result = capture_invalid_message(func, "", "retry", :first_name)
    assert result =~ "That is an invalid input, first_name cannot be empty. Please try again: "
  end 

  test "retry_for_empty_field takes an input" do
    func = &ValidatingInputs.validate_not_empty/2
    result = capture_user_input(func, :first_name, "retry")
    assert result =~ "retry"
  end 

  test "runs through every category to validate inputs" do
    func = &ValidatingInputs.run_validation_checks/0
    result = capture_final_output(func, "\ndaisy\nm\nmolving\nzip-error\n12345\nid-error\nGG-6735")
    assert result =~ "no errors found"
  end

  defp capture_output(func, category) do
    capture_io(fn ->
      func.(category)
    end)
  end

  defp capture_invalid_message(func, invalid_input, retry_input, category) do
    capture_io(retry_input, fn ->
      func.(invalid_input, category)
    end)
  end

  defp capture_user_input(func, category, user_input) do
    capture_io([input: user_input, capture_prompt: false], fn ->
      value = func.(user_input, category)
      IO.write(value)
    end)
  end
  
  defp capture_final_output(func, user_inputs) do
    capture_io(user_inputs, fn ->
      func.()
    end)
  end

end
