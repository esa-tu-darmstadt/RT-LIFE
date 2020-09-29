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

void myprint(char *s)
{
	// do nothing with string
}

void say_hello(char *s)
{
	myprint(s);
}

void hello_athens()
{
	say_hello("Hello Athens !\n");
}

void take_off()
{
	myprint("Bye bye\n");
}

void cruise()
{
	int res = 0;
	int c = 3;

	switch (c) {
		case 1:
			res = 1+1;
			break;
		case 2 :
			res = 3+3;
			break;
		case 3:
			myprint("Nice blue sky\n");
			break;
	}
}

void land()
{
	int x = 1;
	if (x)
		myprint("I can see you from up here\n");
}

void fly()
{

	for (int i=0; i<10; i++) {
		take_off();
		cruise();
		land();
	}
}

void hello_paris()
{
	say_hello("Hello Paris !\n");
}

void hello_los_angeles()
{
	say_hello("Hello Los Angeles !\n");
}

void back()
{
	fly();
}

int main(void)
{
	hello_athens();
	fly();
	hello_paris();
	fly();
	hello_los_angeles();
	back();
}
