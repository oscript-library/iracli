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
		ИмяОбъекта = "кластера";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Серверы Тогда
		ИмяОбъекта = "сервера";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.РабочиеПроцессы Тогда
		ИмяОбъекта = "рабочего процесса";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.ИнформационныеБазы Тогда
		ИмяОбъекта = "информационной базы";
		ПоляПоУмолчанию = "_summary";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Сеансы Тогда
		ИмяОбъекта = "сеанса";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Соединения Тогда
		ИмяОбъекта = "соединения";
		ПоляПоУмолчанию = "_summary";
	КонецЕсли;

	Команда.Опция("i id", "", СтрШаблон("идентификатор %1", ИмяОбъекта))
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении(СтрШаблон("IRAC_%1_ID", ВРег(ТипОбъектовКластера)));
	
	Команда.Опция("f field", ПоляПоУмолчанию, СтрШаблон("список получаемых полей %1", ИмяОбъекта))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_FIELD", ВРег(ТипОбъектовКластера)));

	Команда.Опция("p property", "", СтрШаблон("свойство %1", ИмяОбъекта))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_PROPERTY", ВРег(ТипОбъектовКластера)));
	
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

	Ид          = Команда.ЗначениеОпции("id");
	Формат      = ВРег(Команда.ЗначениеОпции("format"));
	ИмяСвойства = Команда.ЗначениеОпции("property");

	Если ЗначениеЗаполнено(ИмяСвойства) Тогда
		Поля = ИмяСвойства;
	Иначе
		Поля = Команда.ЗначениеОпции("field");
	КонецЕсли;

	Условия = Новый Массив();
	Условия.Добавить(Новый Структура("Оператор, Значение", ОбщегоНазначения.ОператорыСравнения().Равно, Ид));

	Фильтр = Новый Соответствие();
	Если ОбщегоНазначения.ЭтоGUID(Ид) Тогда
		Фильтр.Вставить("id", Условия);
	Иначе
		Фильтр.Вставить("label", Условия);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	ОбъектыКластера = ПодключенияКАгентам.ОбъектыКластера(ТипОбъектовКластера, Истина, Поля, Фильтр);

	Если ОбъектыКластера.Количество() = 0 Тогда
		Результат = Неопределено;
	Иначе
		Результат = ОбъектыКластера[0];
	КонецЕсли;

	Если ЗначениеЗаполнено(ИмяСвойства) Тогда
		Если Результат = Неопределено Тогда
			ЗначениеСвойства = ПодключенияКАгентам.ПустойОбъектКластера(ТипОбъектовКластера, Поля)[ИмяСвойства];
		Иначе
			ЗначениеСвойства = Результат[ИмяСвойства];
		КонецЕсли;
		Если ТипЗнч(ЗначениеСвойства) = Тип("Дата") Тогда
			ЗначениеСвойства = Формат(ЗначениеСвойства, "ДФ=yyyy-MM-ddThh:mm:ss");
		КонецЕсли;
		Результат = Новый Соответствие();
		Результат.Вставить(ИмяСвойства, ЗначениеСвойства);
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Результат) Тогда
		Сообщить(СтрШаблон("Ошибка получения описания объекта кластера %1 по идентификатору ""%2""",
		                   ТипОбъектовКластера,
		                   Ид));
		Возврат;
	КонецЕсли;

	Если Формат = ОбщегоНазначения.ФорматыРезультата().prometheus Тогда
		Результат = ФорматPrometheus(Результат);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().plain Тогда
		Результат = ФорматPlain(Результат);
	Иначе
		Результат = ОбщегоНазначения.ДанныеВJSON(Результат);
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

	ЗначенияИзмеренийСтрокой = "";
	ЗначениеЭлемента = 1;
	Для Каждого ТекПоле Из Данные Цикл

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

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматPrometheus()

Функция ФорматPlain(Данные)

	Текст = Новый Массив();

	Для Каждого ТекПоле Из Данные Цикл
		
		ЗначениеЭлемента = ТекПоле.Значение;
		
		Если НЕ ЗначениеЗаполнено(ЗначениеЭлемента) Тогда
			ЗначениеЭлемента = "";
		КонецЕсли;
		
		Если ТипЗнч(ЗначениеЭлемента) = Тип("Число") Тогда
			ЗначениеЭлемента = Формат(ЗначениеЭлемента, "ЧРД=.; ЧН=; ЧГ=0");
		КонецЕсли;

		Текст.Добавить(СтрШаблон("%1=%2", ТекПоле.Ключ, ЗначениеЭлемента));

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
