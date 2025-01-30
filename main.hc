extern "c" I32 getchar(); // External getchar declaration
extern "c" I32 strcmp(U8 *__s1, U8 *__s2);
extern "c" I64 strlen(U8 *s);
extern "c" U8 *strtok(U8 *__str, U8 *__sep);

#define INITIAL_SIZE 100
#define INITIAL_TOKEN_SIZE 10
#define DELIMITERS " \t\r\n"   // Token separators

// Function to read input into a dynamically allocated buffer
U0 gets(U8 **source) {
    I32 size = INITIAL_SIZE;
    U8 *buffer = MAlloc(size);
    if (!buffer) {
        "Failed to allocate memory\n";
        *source = NULL;
        return;
    }

    I32 i = 0;
    while (1) {
        I32 ch = getchar();
        if (ch == -1 || ch == '\n') {
            buffer[i] = 0;
            break;
        }
        buffer[i++] = ch;

        if (i >= size - 1) {
            size *= 2;
            U8 *new_buffer = ReAlloc(buffer, size);
            if (!new_buffer) {
                "Failed to reallocate memory\n";
                Free(buffer);
                *source = NULL;
                return;
            }
            buffer = new_buffer;
        }
    }

    *source = buffer;
}

// Tokenizer function to split input into tokens
U8 **tokenizer(U8 *input) {
    I64 capacity = INITIAL_TOKEN_SIZE;
    U8 **tokens = MAlloc(capacity * sizeof(U8 *));
    if (!tokens) {
        "Memory allocation error\n";
        return NULL;
    }

    U8 *token = strtok(input, DELIMITERS);
    I64 count = 0;

    while (token) {
        // Allocate and copy token manually (Holy C compatible)
        U8 *token_copy = MAlloc(strlen(token) + 1);
        if (!token_copy) {
            "Token copy failed\n";
            Free(tokens);
            return NULL;
        }
        StrCpy(token_copy, token);

        // Resize token array if needed
        if (count >= capacity - 1) {
            capacity *= 2;
            U8 **new_tokens = ReAlloc(tokens, capacity * sizeof(U8 *));
            if (!new_tokens) {
                "Token resize failed\n";
                Free(tokens);
                return NULL;
            }
            tokens = new_tokens;
        }

        tokens[count++] = token_copy;
        token = strtok(NULL, DELIMITERS);
    }

    tokens[count] = NULL; // NULL-terminate
    return tokens;
}

// Function to free tokens
U0 free_tokens(U8 **tokens) {
    if (!tokens) return;
    for (I64 i = 0; tokens[i]; i++) {
        Free(tokens[i]); // Holy C's Free
    }
    Free(tokens);
}


U0 tokenHandling(U8 **tokens) {
    U8 *cmd = tokens[0];
    I64 argsLength = MAlloc(sizeof(I64));
    //count the length of the array:
    for(I64 i = 1; tokens[i]!=NULL; i++){
      argsLength++;
    }
    U8 **args = MAlloc(sizeof(tokens)-sizeof(tokens[0]));
    for(I64 i = 1; i < argsLength; i++) {
        args[i-1] = tokens[i];
    }
    //TODO: handling system
}


// Main function
U0 Main() {
    U8 *input = NULL;

    while (1) {
        "Holy> ";
        gets(&input);
        if (!input) {
            "Input error\n";
            return;
        }

        // Exit condition
        if (strcmp(input, "exit") == 0) {
            Free(input);
            break;
        }

        // Tokenize input
        U8 **tokens = tokenizer(input);
        if (!tokens) {
            "Tokenization failed\n";
            Free(input);
            continue;
        }
        
        // we shall handle the tokens:
        tokenHandling(tokens);

        free_tokens(tokens);
        Free(input);
    }

    "Cya!\n";
    return;
}
