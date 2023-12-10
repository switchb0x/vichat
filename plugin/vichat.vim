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

function! CheckAPIKey()
    let api_key = $OPENAI_API_KEY
    if empty(api_key)
        echo "OpenAI API key not found in environment variables."
        echo "Please set the OPENAI_API_KEY environment variable."
    else
        echo "OpenAI API key loaded successfully."
    endif
endfunction

" Call the function when Vim starts
call CheckAPIKey()



