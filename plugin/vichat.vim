"Copyright 2023 Zetier
"
"Licensed under the Apache License, Version 2.0 (the "License");
"you may not use this file except in compliance with the License.
"You may obtain a copy of the License at
"
"http://www.apache.org/licenses/LICENSE-2.0
"
"Unless required by applicable law or agreed to in writing, software
"distributed under the License is distributed on an "AS IS" BASIS,
"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"See the License for the specific language governing permissions and
"limitations under the License.

" vichat.vim

function! CheckAPIToken()
    let api_key = $OPENAI_API_TOKEN
    if empty(api_key)
        echo "[vichat plugin] OpenAI API token not found in environment variables."
        echo "Please set the OPENAI_API_TOKEN environment variable."
    else
        "echo "OpenAI API key loaded successfully."
    endif
endfunction

function! VichatPrompt()
    " Capture the selected text
    let selected_text = join(getline("'<", "'>"), "\n")

    " Get additional input from the user
    let user_input = input("Enter additional optional text for GPT-4: ")

    " Combine the selected text and user input
    let full_prompt = selected_text . "\n" . user_input

    let api_url = "https://api.openai.com/v1/engines/davinci-codex/completions"
    let post_data = json_encode({'prompt': full_prompt, 'max_tokens': 100})
    let headers = ['Content-Type: application/json', 'Authorization: Bearer ' . api_key]

    " The list format for the curl command is not needed for system() or systemlist()
    " We'll directly construct the command as a string, which systemlist() will handle properly
    let curl_command = 'curl -s -X POST ' . shellescape(api_url) . ' -H ' . shellescape(headers[0]) . ' -H ' . shellescape(headers[1]) . ' --data ' . shellescape(post_data)

    " Debug: Print the curl command
    echom "Executing command: " . curl_command

    " Execute the curl command and capture the output as a list of lines
    let response = systemlist(curl_command)

    " Check for a shell error
    if v:shell_error
        echom "Shell command failed with error code: " . v:shell_error
        return
    endif

    " Assuming the response is JSON and contains a 'choices' list with at least one element
    " Parse the response to extract the text
    let response_json = json_decode(join(response, ""))
    if has_key(response_json, 'choices')
        let output_text = response_json.choices[0].text
    else
        echom "Error: Invalid response format."
        return
    endif

    " Split the output text into lines for the quickfix list
    let lines = split(output_text, "\n")

    " Create a list for the quickfix window
    let qflist = []
    for idx in range(len(lines))
        call add(qflist, {'text': lines[idx], 'lnum': idx + 1})
    endfor

    " Set the quickfix list and open the quickfix window
    call setqflist(qflist)
    copen
endfunction



" Map the function to a hotkey in visual mode, e.g., gpt4
xnoremap gpt4 :<C-u>call VichatPrompt()<CR>

" Call the function when Vim starts
call CheckAPIToken()


