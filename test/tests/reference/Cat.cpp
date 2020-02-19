#include "Cat.hpp"

Cat::Cat(int age, int legs)
{
    this->age = age;
    this->legs = legs;
}

void Cat::speak(int x)
{
    for (int i = 0; i < x; i++)
    {
	std::cout << "meow\n";
    }
}

int Cat::getAge()
{
    return this->age;
}

int main()
{
    Cat purrcival = Cat(6);
    purrcival.speak(2);
}
