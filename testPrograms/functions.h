/* 
 * Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
 * This file is part of RT-LIFE
 * (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

int answer = 42;

int give_answer()
{
	return answer--;
}

int foo()
{
	return 1337;
}

int bar()
{
	return 42;
}

int baz()
{
	return 1703;
}

int foobar()
{
	return 1742;
}

int add(int a, int b)
{
	return a + b;
}

int linear(int x, int m, int b)
{
	return m*x+b;
}

int square(int x, int a, int b, int c)
{
	return a*x*x + b*x + c;
}
