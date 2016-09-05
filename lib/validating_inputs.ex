defmodule ValidatingInputs do

	def main(_) do
		run_validation_checks
	end

	@user_input_requests	[
				{:first_name, "Please enter your first name: "},
				{:last_name, "Please enter your last name: "},
				{:zip_code, "Please enter your zip code: "},
				{:employee_id, "Please enter your employee id: "}
				]

	@validation_matches 	[
				{:first_name, ~r/\w{2,}/},
				{:last_name,  ~r/\w{2,}/},
				{:zip_code, ~r/\d{5}/},
				{:employee_id, ~r/([A-Z]){2}-\d{4}/} 
				]

	@invalid_type_messages	[
				{:first_name, "That is an invalid input, first name must be at least two characters long. Please try again: "},
				{:last_name, "That is an invalid input, last name must be at least two characters long. Please try again: "},
				{:zip_code, "That is an invalid input, zip code must be numerical and five digits long. Please try again: "}, 
				{:employee_id, "That is an invalid input, employee id must have two letters followed by a hyphen, then four numbers. Please try again: "}
				]

	def run_validation_checks do
		validate_input(@user_input_requests)
	end

	def validate_input([]), do: print_no_found_error_message
	def validate_input([{category, _} | next_input_request]) do
    { String.strip(print_input_request(category)), category }
    |> validate_not_empty
    |> validate_type
    validate_input(next_input_request)
	end

	def validate_not_empty({"", category}) do
    validate_not_empty({String.strip(retry_for_empty_field(category)), category})
	end

  def validate_not_empty(user_input_with_category), do: user_input_with_category

	def validate_type({user_input, category}) do
		cond do
			Regex.match?(@validation_matches[category], String.strip(user_input)) ->
				user_input
			:else ->
				validate_type({retry_for_invalid_type(category), category})
		end
	end

	def print_input_request(category) do
		IO.gets(@user_input_requests[category])
	end

	defp retry_for_empty_field(category) do
		IO.gets("That is an invalid input, #{category} cannot be empty. Please try again: ")
	end

	def retry_for_invalid_type(category) do
		IO.gets(@invalid_type_messages[category])
	end

	defp print_no_found_error_message do
		IO.puts("\nThank you for your information, there were no errors found.")
	end
end
