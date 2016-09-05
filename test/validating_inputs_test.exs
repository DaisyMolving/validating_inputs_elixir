defmodule ValidatingInputsTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ValidatingInputs

  test "prints out each request" do
    result = capture_output(&ValidatingInputs.print_input_request/1, [:first_name, :last_name, :zip_code, :employee_id])
    assert result =~ "Please enter your"
  end

  test "a first name or last name must be at least 2 letters long" do 
    result = capture_invalid_message(&ValidatingInputs.validate_type/1, [{"D", :first_name}, {"M", :last_name}], "daisy\nmolving")
    assert result =~ "must be at least two characters long"
  end 

  test "a zip code must be completely numerical" do
    result = capture_invalid_message(&ValidatingInputs.validate_type/1, [{"ABC4E", :zip_code}], "12345")
    assert result =~ "zip code must be numerical"
  end

  test "an employee id must start with two letters, then a hyphen, then four numbers" do
    result = capture_invalid_message(&ValidatingInputs.validate_type/1, [{"AA1234", :employee_id}], "ZZ-7890")
    assert result =~ "employee id must have two letters followed by a hyphen, then four numbers"
  end

  test "retry_for_empty_field message is printed when field is empty" do
    result = capture_invalid_message(&ValidatingInputs.validate_not_empty/1, [{"", :first_name}, {"", :last_name}, {"", :zip_code}, {"", :employee_id}], "daisy\nmolving\n12345\nRR-7382")
    assert result =~ "cannot be empty. Please try again: "
  end 

  # test "returns string to validate type if it is not empty" do
  #   result = capture_user_input(&ValidatingInputs.validate_not_empty/1, [{"daisy", :first_name}, {"molving", :last_name}, {"12345", :zip_code}, {"AA-1234", :employee_id}])
  #   assert result =~ "daisy\nmolving\n12345\nAA-1234"
  # end 
  
  test "runs through every category to validate inputs" do
    result = capture_final_output(&ValidatingInputs.run_validation_checks/0, "\ndaisy\nm\nmolving\nzip-error\n12345\nid-error\nGG-6735")
    assert result =~ "no errors found"
  end

  # defp capture_user_input(func, inputs_with_categories) do
  #   Enum.each(inputs_with_categories, fn({user_input, category}) ->
  #     capture_io([input: user_input, capture_prompt: false], fn ->
  #       IO.write(user_input)
  #     end)
  #   end)
  # end

  defp capture_invalid_message(func, invalid_inputs_with_categories, retry_input) do
    capture_io(retry_input, fn ->
      Enum.each(invalid_inputs_with_categories, fn(invalid_category_pair) ->
        func.(invalid_category_pair) 
      end)
    end)
  end

  defp capture_output(func, categories) do
    capture_io(fn ->
      Enum.each(categories, fn(category) ->
        func.(category) 
      end)
    end)
  end

  defp capture_final_output(func, user_inputs) do
    capture_io(user_inputs, fn ->
      func.()
    end)
  end

end
