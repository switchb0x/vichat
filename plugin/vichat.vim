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


function! VichatPrompt4_curl(model)
    " Capture the selected text as the system's message (previous context)
    let system_message = getline("'<", "'>")
    let system_message = join(system_message, "\n")

    " Get additional input from the user as the user's message
    let user_message = input("Enter your message for " . a:model . ": ")

    " Construct the messages array with the user and system messages
    let messages = []
    if !empty(system_message)
        call add(messages, {'role': 'system', 'content': system_message})
    endif
    call add(messages, {'role': 'user', 'content': user_message})

    " Construct the data dictionary for the API request
    let data_dict = {
    \ 'model': 'gpt-4',
    \ 'messages': messages,
    \ 'temperature': 0.7
    \ }

    " Encode the data dictionary as JSON
    let post_data_json = json_encode(data_dict)

    let api_url = "https://api.openai.com/v1/chat/completions"
    
    " Write the JSON to a temporary file to avoid shell escaping issues
    let tmpfname = tempname()
    call writefile([post_data_json], tmpfname)
    
    let content_type_header = 'Content-Type: application/json'
    let auth_header = 'Authorization: Bearer ' . g:openai_api_key
    
    " Construct the curl command to use the JSON from the temporary file
    let curl_command = 'curl -s -X POST ' . api_url .
                \ ' -H "' . content_type_header .
                \ '" -H "' . auth_header .
                \ '" --data-binary @' . tmpfname
    
    "echo curl_command

    " Execute the curl command and capture the output as a string
    let response = system(curl_command)
    "echo response

    " Remove the temporary file immediately after use
    call delete(tmpfname)

    " Handle the response
    if response != ""
        try
            let response_json = json_decode(response)
            " If response_json is parsed successfully, handle it
            if has_key(response_json, 'choices') && len(response_json.choices) > 0
                let output_text = response_json.choices[0].message['content']
                let action = input("Replace or insert output? (R/I): ", "R")
                let start_line = getpos("'<")[1]
                let end_line = getpos("'>")[1]
                silent! undojoin
                if toupper(action) == 'R'
                    execute start_line . "," . end_line . "delete _"
                    call append(start_line-1, split(output_text, "\n"))
                elseif toupper(action) == 'I'
                    call append(end_line, split(output_text, "\n"))
                endif
            else
                echoerr "Error: Invalid response format."
            endif
        catch
            echoerr "Error parsing JSON response: " . v:exception
        endtry
    else
        echoerr "Received invalid response from API."
    endif
endfunction

xnoremap gpt :<C-u>call VichatPrompt4_curl('gpt-3.5-turbo')<CR>
xnoremap gpt4 :<C-u>call VichatPrompt4_curl('gpt-4')<CR>
call CheckAPIToken()

