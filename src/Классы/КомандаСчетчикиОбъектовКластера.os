// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/iracli/
// ----------------------------------------------------------

Перем Лог;                  // Объект                               - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Функция - возвращает объект управления логированием
//
// Возвращаемое значение:
//  Объект      - объект управления логированием
//
Функция Лог() Экспорт
	
	Возврат Лог;

КонецФункции // Лог()

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт

	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.Кластеры);
	Команда.ДобавитьКоманду("cluster c", "получение счетчиков кластеров 1С", ОбъектКоманды);

	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.Серверы);
	Команда.ДобавитьКоманду("server s", "получение счетчиков серверов 1С", ОбъектКоманды);
	
	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.РабочиеПроцессы);
	Команда.ДобавитьКоманду("process p", "получение счетчиков рабочих процессов 1С", ОбъектКоманды);
	
	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.ИнформационныеБазы);
	Команда.ДобавитьКоманду("infobase i", "получение счетчиков информационных баз 1С", ОбъектКоманды);
	
	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.Сеансы);
	Команда.ДобавитьКоманду("session ss" , "получение счетчиков сеансов 1С", ОбъектКоманды);
	
	ОбъектКоманды = Новый КомандаСчетчикиОбъектаКластера(Перечисления.РежимыАдминистрирования.Соединения);
	Команда.ДобавитьКоманду("connection cc" , "получение счетчиков соединений 1С", ОбъектКоманды);
	
	ОбъектКоманды = Новый КомандаСписокСчетчиковОбъектовКластера();
	Команда.ДобавитьКоманду("list l" , "получение списка доступных счетчиков объектов кластера 1С", ОбъектКоманды);

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//  ТипОбъектов   - Перечисление.РежимыАдминистрирования    - тип обрабатываемых объектов кластера
// 
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыПриложения.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
