defmodule ValidatingInputsTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ValidatingInputs

  test "prints out each request" do
    result = capture_output(&ValidatingInputs.print_input_request/1, [:first_name, :last_name, :zip_code, :employee_id])
    assert result =~ "Please enter your"
  end

  test "a first name or last name must be at least 2 letters long" do 
    result = capture_invalid_message(&ValidatingInputs.validate_type/2, "D\nM", "daisy\nmolving", [:first_name, :last_name])
    assert result =~ "must be at least two characters long"
  end 

  test "a zip code must be completely numerical" do
    result = capture_invalid_message(&ValidatingInputs.validate_type/2, "ABC4E", "12345", [:zip_code])
    assert result =~ "zip code must be numerical"
  end

  test "an employee id must start with two letters, then a hyphen, then four numbers" do
    result = capture_invalid_message(&ValidatingInputs.validate_type/2, "AA1234", "ZZ-7890", [:employee_id])
    assert result =~ "employee id must have two letters followed by a hyphen, then four numbers"
  end

  test "retry_for_empty_field message is printed when field is empty" do
    result = capture_invalid_message(&ValidatingInputs.validate_not_empty/2, "\n\n\n", "daisy\nmolving\n12345\nRR-7382", [:first_name, :last_name, :zip_code, :employee_id])
    assert result =~ "cannot be empty. Please try again: "
  end 

  test "retry_for_empty_field takes an input" do
    result = capture_user_input(&ValidatingInputs.validate_not_empty/2, [:first_name, :last_name, :zip_code, :employee_id], "daisy\nmolving\n12345\nAA-12345")
    assert result =~ "daisy\nmolving\n12345\nAA-12345"
  end 
  
  test "runs through every category to validate inputs" do
    result = capture_final_output(&ValidatingInputs.run_validation_checks/0, "\ndaisy\nm\nmolving\nzip-error\n12345\nid-error\nGG-6735")
    assert result =~ "no errors found"
  end

  defp capture_output(func, categories) do
    capture_io(fn ->
      Enum.each(categories, fn(category) ->
        func.(category) 
      end)
    end)
  end

  defp capture_invalid_message(func, invalid_input, retry_input, categories) do
    capture_io(retry_input, fn ->
      Enum.each(categories, fn(category) ->
        func.(invalid_input, category) 
      end)
    end)
  end

  defp capture_user_input(func, categories, user_input) do
    capture_io([input: user_input, capture_prompt: false], fn ->
      Enum.each(categories, fn(category) ->
        value = func.(user_input, category)
        IO.write(value)
      end)
    end)
  end

  defp capture_final_output(func, user_inputs) do
    capture_io(user_inputs, fn ->
      func.()
    end)
  end

end
