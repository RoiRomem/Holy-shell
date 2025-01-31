// External declarations (use correct HolyC types)
extern "c" I32 getchar(); 
public _extern _STRCMP I64 StrCmp(U8 *s1, U8 *s2);
extern "c" U8 *strtok(U8 *__str, U8 *__sep);
public _extern _STRCPY U0 StrCpy(U8 *dst, U8 *src);
public _extern _STRLEN_FAST U64 StrLen(U8 *buf);

// Constants
#define INITIAL_SIZE 100
#define INITIAL_TOKEN_SIZE 10
#define DELIMITERS " \t\r\n"
#define NUM_OF_CMDS 2

// Command class
class Command {
    U8 *cmd;
    U0 (*commandFunction)(U8 **args); // Function pointer now expects args as an argument
};

U0 commandRunnner(U8 **args, U0 (*proc)(U8 **args)) {
    proc(args);
}

// Global variables
I64 argsLength = 0;
U8 **args; // Global args
Command *commandList;

// Command functions
U0 ExitCmd(U8 **args) {
    "bye bye\n";
    Exit;
}

U0 EchoCmd(U8 **args) {
    for (I64 i = 0; i < argsLength-1; i++) {
        "%s ", args[i];
    }
    "\n";
}

// Initialize commands
Command *SetCommands() {
    Command *cmds = MAlloc(sizeof(Command) * NUM_OF_CMDS);

    cmds[0].cmd = "exit";  
    cmds[0].commandFunction = &ExitCmd;  // Use address-of operator for function pointer
    
    cmds[1].cmd = "echo";
    cmds[1].commandFunction = &EchoCmd;  // Use address-of operator for function pointer

    return cmds;
}

// Dynamic input reader
U0 Gets(U8 **source) {
    I32 size = INITIAL_SIZE;
    U8 *buffer = MAlloc(size);
    I32 i = 0, ch;

    while (1) {
        ch = getchar();
        if (ch == -1 || ch == '\n') {
            buffer[i] = 0;
            break;
        }
        buffer[i++] = ch;
        if (i >= size-1) {
            size *= 2;
            U8 *new_buffer = MAlloc(size); // Allocate new buffer
            StrCpy(new_buffer, buffer);    // Copy old data to new buffer
            Free(buffer);                  // Free old buffer
            buffer = new_buffer;           // Point to new buffer
        }
    }
    *source = buffer;
}

// Tokenizer
U8 **Tokenizer(U8 *input) {
    I64 token_capacity = INITIAL_TOKEN_SIZE; // Use a variable for dynamic resizing
    U8 **tokens = MAlloc(token_capacity * sizeof(U8*));
    U8 *token = strtok(input, DELIMITERS);
    I64 count = 0;

    while (token) {
        tokens[count] = MAlloc(StrLen(token)+1);
        StrCpy(tokens[count], token);
        count++;
        if (count >= token_capacity-1) {
            token_capacity *= 2; // Double the capacity
            U8 **new_tokens = MAlloc(token_capacity * sizeof(U8*)); // Allocate new tokens array
            for (I64 j = 0; j < count; j++) {
                new_tokens[j] = tokens[j]; // Copy old tokens to new array
            }
            Free(tokens);                  // Free old tokens array
            tokens = new_tokens;           // Point to new tokens array
        }
        token = strtok(NULL, DELIMITERS);
    }
    tokens[count] = NULL;
    return tokens;
}

// Main shell
U0 Shell() {
    commandList = SetCommands();
    U8 *input;

    while (TRUE) {
        "Holy> ";
        Gets(&input);
        if (!input || input[0] == '\0') continue;  // Skip empty input

        U8 **tokens = Tokenizer(input);
        if (tokens && tokens[0]) {
            // Set up args
            argsLength = 0;
            while (tokens[argsLength]) argsLength++;  // Count the number of tokens
            args = tokens + 1;  // HolyC allows array pointer arithmetic

            // Execute command
            for (I64 i = 0; i < NUM_OF_CMDS; i++) {
                if (StrCmp(commandList[i].cmd, tokens[0]) == 0) {
                    commandRunnner(args, commandList[i].commandFunction);
                    goto done;
                }
            }
            "Unknown command: %s\n", tokens[0];
        }
done:
        Free(input);
        if (tokens) {
            for (I64 i = 0; tokens[i]; i++) Free(tokens[i]);
            Free(tokens);
        }
    }
}

// Entry point
Shell();
