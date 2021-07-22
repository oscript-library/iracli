// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/iracli/
// ----------------------------------------------------------

Перем ТипОбъектовКластера;  // Перечисление.РежимыАдминистрирования - тип обрабатываемых объектов кластера

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
	
	ПоляПоУмолчанию = "_all";

	Если ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Кластеры Тогда
		ИмяОбъектов = "кластеров";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Серверы Тогда
		ИмяОбъектов = "серверов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.РабочиеПроцессы Тогда
		ИмяОбъектов = "рабочих процессов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.ИнформационныеБазы Тогда
		ИмяОбъектов = "информационных баз";
		ПоляПоУмолчанию = "_summary";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Сеансы Тогда
		ИмяОбъектов = "сеансов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Соединения Тогда
		ИмяОбъектов = "соединений";
		ПоляПоУмолчанию = "_summary";
	КонецЕсли;

	Команда.Опция("f field", ПоляПоУмолчанию, СтрШаблон("список получаемых полей %1,
	                                                    |разделенный запятыми", ИмяОбъектов))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_LIST_FIELD", ВРег(ТипОбъектовКластера)));

	Команда.Опция("fl filter", "", СтрШаблон("фильтр %1 по значениям полей,
	                                         |выражения фильтра разделяются запятыми
	                                         |(пример: ""eq_name=имя,eq_count=1"")", ИмяОбъектов))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_LIST_FILTER", ВРег(ТипОбъектовКластера)));

	Команда.Опция("s sort", "", СтрШаблон("сортировка %1 по значениям полей,
	                                      |имена полей разделяются запятыми", ИмяОбъектов))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_LIST_SORT", ВРег(ТипОбъектовКластера)));

	Команда.Опция("t top", 0, СтрШаблон("отбор %1 с максимальным значением поля,
	                                    |указанного в параметре top-field", ИмяОбъектов))
	       .ТЧисло()
	       .ВОкружении(СтрШаблон("IRAC_%1_LIST_TOP", ВРег(ТипОбъектовКластера)));

	Команда.Опция("tf top-field", "count", СтрШаблон("поле для отбора top первых %1", ИмяОбъектов))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_LIST_TOP_FIELD", ВРег(ТипОбъектовКластера)));

	Команда.Опция("fm format", "json", "формат вывода данных (json, plain, prometheus)")
	       .ТСтрока()
	       .ВОкружении("IRAC_RESULT_FORMAT");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ВыводОтладочнойИнформации = Команда.ЗначениеОпции("verbose");

	ПараметрыПриложения.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	ПараметрыЗамера = ЗамерыВремени.НачатьЗамерКоманды(Команда);

	Поля             = Команда.ЗначениеОпции("field");
	ФильтрСтрокой    = Команда.ЗначениеОпции("filter");
	Сортировка       = Команда.ЗначениеОпции("sort");
	ПервыеКоличество = Команда.ЗначениеОпции("top");
	ПервыеИмяПоля    = Команда.ЗначениеОпции("top-field");
	Формат           = ВРег(Команда.ЗначениеОпции("format"));

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ФильтрСтрокой);

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	ОбъектыКластера = ПодключенияКАгентам.ОбъектыКластера(ТипОбъектовКластера, Истина, Поля, Фильтр);

	Если ПервыеКоличество > 0 Тогда
		ОбъектыКластера = ОбщегоНазначения.ПервыеПоЗначениюПоля(ОбъектыКластера, ПервыеИмяПоля, ПервыеКоличество);
	ИначеЕсли ЗначениеЗаполнено(Сортировка) Тогда
		ОбщегоНазначения.СортироватьДанные(ОбъектыКластера, Сортировка);
	КонецЕсли;

	Если Формат = ОбщегоНазначения.ФорматыРезультата().prometheus Тогда
		Результат = ФорматPrometheus(ОбъектыКластера);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().plain Тогда
		Результат = ФорматPlain(ОбъектыКластера);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(ОбъектыКластера);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Сообщить(Результат);

КонецПроцедуры // ВыполнитьКоманду()

Функция ФорматPrometheus(Данные)

	Текст = Новый Массив();

	ЗаголовокЭлемента = СтрЗаменить(ТипОбъектовКластера, "-", "_");

	ОписаниеЭлемента = "";

	Текст.Добавить(СтрШаблон("# HELP %1 %2", ЗаголовокЭлемента, ОписаниеЭлемента));
	Текст.Добавить(СтрШаблон("# TYPE %1 gauge", ЗаголовокЭлемента));

	Для Каждого ТекЭлемент Из Данные Цикл

		ЗначенияИзмеренийСтрокой = "";
		ЗначениеЭлемента = 1;
		Для Каждого ТекПоле Из ТекЭлемент Цикл
			Если ВРег(ТекПоле.Ключ) = "COUNT" Тогда
				Продолжить;
			КонецЕсли;
			
			ЗначениеИзмерения = ТекПоле.Значение;
			Если ТипЗнч(ЗначениеИзмерения) = Тип("Дата") Тогда
				ЗначениеИзмерения = Формат(ЗначениеИзмерения, "ДФ=yyyy-MM-ddThh:mm:ss");
			КонецЕсли;
			ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
										?(ЗначенияИзмеренийСтрокой = "", "", ",") +
										СтрШаблон("%1=""%2""", СтрЗаменить(ТекПоле.Ключ, "-", "_"), ЗначениеИзмерения);
		КонецЦикла;
		
		Текст.Добавить(СтрШаблон("%1{%2} %3",
		                         ЗаголовокЭлемента,
		                         ЗначенияИзмеренийСтрокой,
		                         ЗначениеЭлемента));
	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматPrometheus()

Функция ФорматPlain(Данные)

	Текст = Новый Массив();

	Для Каждого ТекЭлемент Из Данные Цикл

		Для Каждого ТекПоле Из ТекЭлемент Цикл
		
			ЗначениеЭлемента = ТекПоле.Значение;
			
			Если НЕ ЗначениеЗаполнено(ЗначениеЭлемента) Тогда
				ЗначениеЭлемента = "";
			КонецЕсли;
			
			Если ТипЗнч(ЗначениеЭлемента) = Тип("Число") Тогда
				ЗначениеЭлемента = Формат(ЗначениеЭлемента, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;

			Текст.Добавить(СтрШаблон("%1=%2", ТекПоле.Ключ, ЗначениеЭлемента));

		КонецЦикла;

		Текст.Добавить(" ");

	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматPlain()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// Параметры:
//  ТипОбъектов   - Перечисление.РежимыАдминистрирования    - тип обрабатываемых объектов кластера
// 
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта(Знач ТипОбъектов)

	ТипОбъектовКластера = ТипОбъектов;

	Лог = ПараметрыПриложения.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
