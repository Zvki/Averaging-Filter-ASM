#include "tchar.h"
#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>
#include <SFML/System.hpp>
#include <iostream>

extern "C" void __fastcall ApplyAverageFilter(unsigned char* input, unsigned char* output, int width, int height, uint32_t radius);

// Funkcja filtru uśredniającego
sf::Image applyAverageFilter(const sf::Image& inputImage, int radius = 2) {
    sf::Image outputImage;
    outputImage.create(inputImage.getSize().x, inputImage.getSize().y);

    int width = inputImage.getSize().x;
    int height = inputImage.getSize().y;

    for (int y = 0; y < height; ++y) {
        std::cout << y << std::endl;
        for (int x = 0; x < width; ++x) {
            int rSum = 0, gSum = 0, bSum = 0;
            int count = 0;

            for (int ky = -radius; ky <= radius; ++ky) {
                for (int kx = -radius; kx <= radius; ++kx) {
                    int nx = x + kx;
                    int ny = y + ky;

                    if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                        sf::Color color = inputImage.getPixel(nx, ny);
                        rSum += color.r;
                        gSum += color.g;
                        bSum += color.b;
                        ++count;
                    }
                }
            }

            sf::Color newColor(
                rSum / count,
                gSum / count,
                bSum / count
            );
            outputImage.setPixel(x, y, newColor);
        }
    }

    return outputImage;
}

// Funkcja stosująca filtr i zapisująca wynik
void applyFilterAndSave(const sf::Image& inputImage, const std::string& outputPath, int radius, int iterations) {
    sf::Image filteredImage = inputImage;
    for (int i = 0; i < iterations; ++i) {
        filteredImage = applyAverageFilter(filteredImage, radius);
    }

    if (filteredImage.saveToFile(outputPath)) {
        std::cout << "Zapisano przefiltrowany obraz: " << outputPath << std::endl;
    }
    else {
        std::cerr << "Nie udalo sie zapisac obrazu: " << outputPath << std::endl;
    }
}

int _tmain(int argc, _TCHAR* argv[]) {
    int x = 3, y = 4, z = 0;

    // Ustawienia okna
    const unsigned int windowWidth = 800;
    const unsigned int windowHeight = 600;

    sf::RenderWindow window(sf::VideoMode(windowWidth, windowHeight), "Filtr usredniajacy");
    window.setFramerateLimit(60);

    // Nagłówek
    sf::Font font;
    if (!font.loadFromFile("D:\\Informatyka\\JA\\proba2\\JASol\\x64\\Release\\FunnelSans-Regular.ttf")) {
        std::cerr << "Nie mozna wczytac czcionki arial.ttf. Uzywam czcionki domyslnej." << std::endl;
    }

    sf::Text headerText("Filtr usredniajacy", font, 30);
    headerText.setFillColor(sf::Color::White);
    headerText.setOrigin(headerText.getLocalBounds().width / 2, headerText.getLocalBounds().height / 2);
    headerText.setPosition(windowWidth / 2, 30);

    // Pole tekstowe z domyślną ścieżką
    sf::RectangleShape fileSelectBox(sf::Vector2f(600, 50));
    fileSelectBox.setPosition(windowWidth / 2 - 300, 100);
    fileSelectBox.setFillColor(sf::Color(200, 200, 200));

    std::string basePath = "D:/";
    std::string fileName = "";
    sf::Text userInput(basePath, font, 20);
    userInput.setPosition(windowWidth / 2 - 280, 115);
    userInput.setFillColor(sf::Color::Black);

    // Przyciski
    sf::RectangleShape buttonCpp(sf::Vector2f(150, 50));
    buttonCpp.setPosition(windowWidth / 2 - 200, 200);
    buttonCpp.setFillColor(sf::Color(100, 200, 100));

    sf::Text buttonCppText("C++", font, 20);
    buttonCppText.setPosition(windowWidth / 2 - 150, 215);
    buttonCppText.setFillColor(sf::Color::White);

    sf::RectangleShape buttonAsm(sf::Vector2f(150, 50));
    buttonAsm.setPosition(windowWidth / 2 + 50, 200);
    buttonAsm.setFillColor(sf::Color(100, 100, 200));

    sf::Text buttonAsmText("asm", font, 20);
    buttonAsmText.setPosition(windowWidth / 2 + 90, 215);
    buttonAsmText.setFillColor(sf::Color::White);

    // Pętla główna
    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();

            // Obsługa pola tekstowego (dodawanie tekstu)
            if (event.type == sf::Event::TextEntered) {
                if (event.text.unicode == '\b' && !fileName.empty()) {
                    fileName.pop_back();
                }
                else if (event.text.unicode < 128 && event.text.unicode != '\b') {
                    fileName += static_cast<char>(event.text.unicode);
                }
                userInput.setString(basePath + fileName);
            }

            // Obsługa kliknięcia przycisków
            if (event.type == sf::Event::MouseButtonPressed) {
                sf::Vector2i mousePos = sf::Mouse::getPosition(window);
                if (buttonCpp.getGlobalBounds().contains(mousePos.x, mousePos.y)) {
                    std::string fullPath = basePath + fileName;
                    sf::Image image;
                    if (image.loadFromFile(fullPath)) {
                        std::cout << "Poprawnie wczytano obraz: " << fullPath << std::endl;
                        applyFilterAndSave(image, basePath + "wynik.png", 5, 3); // Radius=2 (5x5), 3 iteracje
                    }
                    else {
                        std::cerr << "Nie udalo sie wczytac obrazu: " << fullPath << std::endl;
                    }
                }
                if (buttonAsm.getGlobalBounds().contains(mousePos.x, mousePos.y)) {
                    std::string fullPath = basePath + fileName;
                    sf::Image inputImage, outputImage;

                    if (inputImage.loadFromFile(fullPath)) {
                        std::cout << "Poprawnie wczytano obraz: " << fullPath << std::endl;

                        // Przygotowanie obrazu wyjściowego
                        outputImage.create(inputImage.getSize().x, inputImage.getSize().y);

                        uint32_t x = 2;

                        // Wywołanie funkcji assemblerowej
                        ApplyAverageFilter(const_cast<unsigned char*>(inputImage.getPixelsPtr()),
                            const_cast<unsigned char*>(outputImage.getPixelsPtr()),
                            inputImage.getSize().x, inputImage.getSize().y, x);

                        // Zapisanie przetworzonego obrazu
                        if (outputImage.saveToFile(basePath + "wynik_asm.png")) {
                            std::cout << "Zapisano przefiltrowany obraz (asm): "
                                << basePath + "wynik_asm.png" << std::endl;
                        }
                        else {
                            std::cerr << "Nie udalo sie zapisac obrazu: "
                                << basePath + "wynik_asm.png" << std::endl;
                        }
                    }
                    else {
                        std::cerr << "Nie udalo sie wczytac obrazu: " << fullPath << std::endl;
                    }
                }
            }
        }

        // Rysowanie
        window.clear();
        window.draw(headerText);
        window.draw(fileSelectBox);
        window.draw(userInput);
        window.draw(buttonCpp);
        window.draw(buttonCppText);
        window.draw(buttonAsm);
        window.draw(buttonAsmText);
        window.display();
    }

    return 0;
}