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
        let g:openai_api_key = api_key
    endif
endfunction

function! VichatPrompt_curl()
    " Capture the selected text
    let selected_text = join(getline("'<", "'>"), "\n")

    " Get additional input from the user
    let user_input = input("Enter additional optional text for GPT-4: ")

    " Combine the selected text and user input
    let full_prompt = selected_text . "\n" . user_input

    let api_url = "https://api.openai.com/v1/completions"
    let post_data = json_encode({'model': 'text-davinci-003', 'prompt': full_prompt, 'max_tokens': 100, 'temperature': 0.7})
    let headers = 'Content-Type: application/json' . ' Authorization: Bearer ' . g:openai_api_key
    
    " Construct the curl command with separate -H options for each header
    let curl_command = 'curl -s -X POST ' . shellescape(api_url) . ' -H ' . shellescape('Content-Type: application/json') . ' -H ' . shellescape('Authorization: Bearer ' . g:openai_api_key) . ' -d ' . shellescape(post_data)
 
    " Debug: Print the curl command to verify it's correct
    echom "Curl command: " . curl_command
    
    " Execute the curl command and capture the output
    let response = systemlist(curl_command)
    
    " After executing the curl command
    echom "Raw API Response: " . join(response, "\n")

    " Error Handling
    if v:shell_error
        echom "Shell command failed with error code: " . v:shell_error
        return
    endif

    " Parse JSON response
    try
        let response_json = json_decode(join(response, ""))
    catch
        echom "Error parsing JSON response."
        return
    endtry

    " Extract text from response
    if has_key(response_json, 'choices') && len(response_json.choices) > 0
        let output_text = response_json.choices[0].text
    else
        echom "Error: Invalid response format."
        return
    endif

    " Process and display output
    let lines = split(output_text, "\n")
    let qflist = []
    for idx in range(len(lines))
        call add(qflist, {'text': lines[idx], 'lnum': idx + 1})
    endfor
    call setqflist(qflist)
    copen
endfunction

xnoremap gpt4 :<C-u>call VichatPrompt_curl()<CR>
call CheckAPIToken()

