# эта реализация должна имплементировать интерфейс CursorInterface
# а конструктор должен принимать массив
# для враппинга аранго-курсора надо изготовить курсор с этим же интерфейсом, но его конструктор должен принимать нативный аранго курсор
# для враппинга монго-курсора надо изготовить курсор с этим же интерфейсом, но его конструктор должен принимать нативный монго курсор
# цель этих курсоров в том, что они должны в зависимости от того, установлен ли класс Делегата либо выдавать в качестве итемов инстансы суб-классов класса Record, либо если делегат не установлен, просто отдавать чистые структуры, которые возвращает база данных.