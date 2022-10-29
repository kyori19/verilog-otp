# verilog-otp

VerilogHDL implementation of One-Time Password Algorithm (HOTP)

## Modules

### SHA1

Implementation of [RFC-3174](https://www.ietf.org/rfc/rfc3174.txt) US Secure Hash Algorithm 1 (SHA-1).
Takes 81 clocks for processing each block.

| direction | width |   name   | details |
|:---------:|------:|:--------:|:--------|
| input     | 1     | clk      | clock   |
| input     | 1     | reset    | positive reset, must be turned on before each hash calculation |
| input     | 1     | feed     | positive feed flag, must be turned on before each message block input |
| input     | 512   | message  | message input, must be padded with the rule defined in SHA-1 |
| output    | 160   | hash     | hash output, could be read if done == 1 |
| output    | 1     | done     | process ended flag, turned on at the end of the process of each block |

### TestSHA1

Tests SHA1 module.

### HMACSHA1

**LIMITED** implementation of HMAC-SHA-1, [RFC-2104](https://www.ietf.org/rfc/rfc2104.txt) Keyed-Hashing for Message Authentication (HMAC) with SHA-1.
Takes at most 250 clocks for processing.

This module accepts **at most one block of message input (512 bytes)** because it is enough to generate HOTP.

| direction | width |      name      | details |
|:---------:|------:|:--------------:|:--------|
| input     | 1     | clk            | clock   |
| input     | 1     | reset          | positive reset, must be turned on before each hash calculation |
| input     | 512   | input_message  | message input, must be padded with the rule defined in SHA-1 but length of the message should be 512 + len(input_message) |
| input     | 512   | key            | key input, must be padded with zeros as defined in HMAC |
| output    | 160   | hash           | hash output, could be read if done == 1 |
| output    | 1     | done           | process ended flag, turned on at the end of the process |

### TestHMACSHA1

Tests HMACSHA1 module.

### HOTP

Implementation of [RFC-4226](https://www.ietf.org/rfc/rfc4226.txt) HOTP: An HMAC-Based One-Time Password Algorithm.
Takes at most 250 clocks for processing.

This module only supports 6-digit output.

| direction | width |      name      | details |
|:---------:|------:|:--------------:|:--------|
| input     | 1     | clk            | clock   |
| input     | 1     | reset          | positive reset, must be turned on before each password calculation |
| input     | 512   | key            | key input, must be padded with zeros as defined in HMAC |
| input     | 64    | counter        | counter value, incremented by 1 for HOTP |
| output    | 20    | code           | 6-digit password output, could be read if done == 1 |
| output    | 1     | done           | process ended flag, turned on at the end of the process |

### TestHOTP

Tests HOTP module.

### GenClock

Clock generator, for test purpose.

## Support for Time-Based One-Time Password (TOTP)

You have to prepare a way to get accurate UNIX Time.
Just provide `(UNIX Time in seconds) / 30` into HOTP module as `counter` value.

## License

```LICENSE
MIT License

Copyright (c) 2022 kyori19

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
