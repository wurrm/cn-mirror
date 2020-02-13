#include <iostream>

;class Cat
{private:

;int age
;int legs

;public:

;Cat(int age, int legs = 4)
{this->age = age
;this->legs = legs

;};void speak(int x)
{for (int i = 0; i < x; i++)
{std::cout << "meow\n"

;};};int getAge()
{return this->age

;};};int main()
{Cat purrcival = Cat(6)
;purrcival.speak(2)
;};
