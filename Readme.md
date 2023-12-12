# Vichat

Vichat is a Vim plugin for predicting text with OpenAI's GPT-4 model.

## Installation

1. Download the latest version of the plugin from the [GitHub repository](https://github.com/zetier/vichat).
2. Unzip the downloaded file.
3. Copy the `vichat.vim` file into your `~/.vim/plugin` folder.
4. Set the `OPENAI_API_TOKEN` environment variable with your OpenAI API token.

## Usage

Once the plugin is installed, you can use the `gpt` command to predict text with GPT-4.

To use the command, highlight the text you want to use as the prompt, then enter `gpt`. You will then be asked to enter some additional optional text for GPT-4.

Once you enter the additional text, GPT-4 will generate the predicted text and you will be asked if you want to replace or insert the output.

## License

This plugin is released under the Apache License, Version 2.0. See the [LICENSE](LICENSE) file for details.

