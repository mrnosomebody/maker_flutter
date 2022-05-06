# where_to_go

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Flutter

## 1. Все во Flutter является виджетом, т.е., по сути, обычным классом в языке Dart, но чтобы он стал виджетом, необходимо, чтобы он наследовался от `StatelessWidget` или `StatefullWidget`
## 2. Виджеты описывают, как должен выглядеть UI приложения
- ## У каждого метода есть основной метод `build()`, который строит и отрисовывает виджет. Он принимает параметр context. Контекст - метаинформация о виджете, его положение в дереве виджетов. Т.е. виджет может содержать в себе другие виджеты
- ## `MaterialApp()` - основа построения `material` дизайна. Занимается всей внутрянкой(отрисовкой, построением и т.д) сама. 
    * ## title - название
    * ## home - виджет, отображаемый на домашней странице
## 3. `Scaffold()` - виджет, который содержит набор виджетов и создает каркас приложения(реализует базовый стиль)
#
# Widgets
## 1. Видимые
   - ## Все, с чем мы можем работать (`Text, Button, Card, Icon...`)
## 2. Невидимые
   - ## Виджеты, которые мы не видим. Составляют верстку проекта (`Row, Column, ListView, GridView...`), контролируют расположение видимых виджетов
## `Container` относится к обеим категориям
#
# Верстка basics
## Один из основных подходов - вертикальное и горизонтальное расположение виджетов (`Column` и `Row` соответственно. Эти виджеты не скроллятся)
![Screenshot_20220320_010957](https://user-images.githubusercontent.com/73302906/159126636-5964c373-72fa-4e39-abb9-2350047c168d.png)
#
 1. ## `Container`
    - ## `width`
    - ## `height`
    - ## `decoration`
        * ## `color: Colors.red`
        * ## `border: Border.all()`
    - ## `child: Some widget` (`Row` or `Column` for instance)
2. ## `Row` or `Column`
    - ## `mainAxisSize`
        * ## `.min` - ужимается до потомков
        * ## `.max` - вся ширина
    - ## `mainAxisAlignment: MainAxisAlignment.center` - выравнивание по главной оси (горизонталь).
     ## Чтобы работало нужно, чтобы `mainAxisSize` стояло в `.max`
    - ## `crossAxisAlignment: CrossAxisAlignment.start` - выравнивание по второстепенной оси (вертикаль)
    - ## `children: <Widget>[Box(), Box(), Box()]`- что лежит внутри виджета
