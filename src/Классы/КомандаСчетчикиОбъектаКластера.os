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
	
	Если ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Кластеры Тогда
		ИмяОбъектов = "кластеров";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Серверы Тогда
		ИмяОбъектов = "серверов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.РабочиеПроцессы Тогда
		ИмяОбъектов = "рабочих процессов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.ИнформационныеБазы Тогда
		ИмяОбъектов = "информационных баз";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Сеансы Тогда
		ИмяОбъектов = "сеансов";
	ИначеЕсли ТипОбъектовКластера = Перечисления.РежимыАдминистрирования.Соединения Тогда
		ИмяОбъектов = "соединений";
	КонецЕсли;

	ОбъектКоманды = Новый КомандаСписокСчетчиковОбъектовКластера(ТипОбъектовКластера);
	Команда.ДобавитьКоманду("list l" ,
	                        СтрШаблон("получение списка доступных счетчиков %1 1С", ИмяОбъектов),
	                        ОбъектКоманды);

	Команда.Опция("c counter", "", "имя счетчика")
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER", ВРег(ТипОбъектовКластера)));

	Команда.Опция("d dim", "_all", "имена полей по которым выполняется свертка значений счетчика")
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER_DIM", ВРег(ТипОбъектовКластера)));

	Команда.Опция("fl filter", "", СтрШаблон("фильтр %1 по значениям полей (пример: eq_name=имя)", ИмяОбъектов))
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER_FILTER", ВРег(ТипОбъектовКластера)));

	Команда.Опция("t top", 0, "отбор указанного количество первых наибольших значений счетчика")
	       .ТЧисло()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER_TOP", ВРег(ТипОбъектовКластера)));
	
	Команда.Опция("a aggregate", "", "агрегатная функция свертки значений счетчика")
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER_AGGREGATE", ВРег(ТипОбъектовКластера)));
	
	Команда.Опция("f format", "json", "формат вывода результатов (json|prometheus|plain)")
	       .ТСтрока()
	       .ВОкружении(СтрШаблон("IRAC_%1_COUNTER_FORMAT", ВРег(ТипОбъектовКластера)));
	
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

	Счетчик           = Команда.ЗначениеОпции("counter");
	Измерения         = Команда.ЗначениеОпции("dim");
	ФильтрСтрокой     = Команда.ЗначениеОпции("filter");
	АгрегатнаяФункция = Команда.ЗначениеОпции("aggregate");
	ПервыеКоличество  = Команда.ЗначениеОпции("top");
	ПервыеИмяПоля     = "_value desc";
	Формат            = ВРег(Команда.ЗначениеОпции("format"));

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ФильтрСтрокой);

	ПараметрыСчетчиков = Настройки.ПараметрыСчетчиков();
	ПараметрыСчетчиковТипаОбъектов = ПараметрыСчетчиков[ТипОбъектовКластера];

	Поля = "";

	Для Каждого ТекИзмерение Из ПараметрыСчетчиковТипаОбъектов["dimentions"] Цикл
		Если ТекИзмерение.Значение["name_rac"] = Неопределено Тогда
			ИмяПоля = ТекИзмерение.Ключ;
		Иначе
			ИмяПоля = ТекИзмерение.Значение["name_rac"];
		КонецЕсли;
		Поля = Поля + ?(ЗначениеЗаполнено(Поля), ", ", "") + ИмяПоля;
	КонецЦикла;

	Для Каждого ТекСчетчик Из ПараметрыСчетчиковТипаОбъектов["counters"] Цикл
		Если ТекСчетчик.Значение["name_rac"] = Неопределено Тогда
			ИмяПоля = ТекСчетчик.Ключ;
		Иначе
			ИмяПоля = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;
		Если ЗначениеЗаполнено(Счетчик) И НЕ ВРег(Счетчик) = ВРег(ИмяПоля) Тогда
			Продолжить;
		КонецЕсли;
		Поля = Поля + ?(ЗначениеЗаполнено(Поля), ", ", "") + ИмяПоля;
	КонецЦикла;

	Поля = ?(ЗначениеЗаполнено(Поля), Поля, "_all");

	ЗамерыВремени.ЗафиксироватьПодготовкуПараметров(ПараметрыЗамера);

	ОбъектыКластера = ПодключенияКАгентам.ОбъектыКластера(ТипОбъектовКластера, Истина, Поля, Фильтр);

	Счетчики = ПолучениеСчетчиков.Счетчики(ОбъектыКластера,
	                                       ТипОбъектовКластера,
	                                       Счетчик,
	                                       Измерения,
	                                       АгрегатнаяФункция);

	Если ПервыеКоличество > 0 Тогда
		Для Каждого ТекЭлемент Из Счетчики.Счетчики Цикл
			ОбщегоНазначения.СортироватьДанные(ТекЭлемент.Значение["values"], ПервыеИмяПоля);
			ТекЭлемент.Значение["values"] = ОбщегоНазначения.Первые(ТекЭлемент.Значение["values"], ПервыеКоличество);
		КонецЦикла;
	КонецЕсли;

	Если Формат = ОбщегоНазначения.ФорматыРезультата().prometheus Тогда
		Результат = ФорматPrometheus(Счетчики.Счетчики, Счетчики.Префикс);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().plain Тогда
		Результат = ФорматPlain(Счетчики.Счетчики, Счетчики.Префикс);
	ИначеЕсли Формат = ОбщегоНазначения.ФорматыРезультата().valueOnly Тогда
		Результат = ФорматPlain(Счетчики.Счетчики, Счетчики.Префикс, Истина);
	Иначе
		Результат = ФорматJSON(Счетчики.Счетчики, Счетчики.Префикс);
	КонецЕсли;

	ЗамерыВремени.ЗафиксироватьОкончаниеЗамера(ПараметрыЗамера);

	Сообщить(Результат);

КонецПроцедуры // ВыполнитьКоманду()

// Функция - преобразует переданные значения счетчиков в формат JSON
//
// Параметры:
//   Счетчики                 - Соответствие              - счетчики для преобразования
//     * <Имя счетчика>         - Соответствие              - содержимое счетчика
//       ** description           - Строка                    - описание счетчика из параметров
//       ** values                - Массив из Соответствие    - значения счетчика
//          *** <Имя измерения>     - Строка                    - значение измерения счетчика
//          *** _value              - Число, Дата, Булево       - значение счетчика
//
//   Префикс       - Строка           - строковый префикс счетчиков,
//                                      который будет добавлен к именам счетчиков в результате
//
// Возвращаемое значение:
//   Строка                 - значения счетчиков в формате JSON
//
Функция ФорматJSON(Счетчики, Префикс = "")

	Результат = Новый Соответствие();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		ЗаголовокСчетчика = СтрШаблон("%1%2", Префикс, ТекСчетчик.Ключ);

		Результат.Вставить(ЗаголовокСчетчика, ТекСчетчик.Значение);

	КонецЦикла;

	Возврат ОбщегоНазначения.ДанныеВJSON(Результат);

КонецФункции // ФорматJSON()

// Функция - преобразует переданные значения счетчиков в формат Prometheus
//
// Параметры:
//   Счетчики      - Соответствие     - счетчики для преобразования
//   Префикс       - Строка           - строковый префикс счетчиков,
//                                      который будет добавлен к именам счетчиков в результате
//
// Возвращаемое значение:
//   Строка                 - значения счетчиков в формате Prometheus
//
Функция ФорматPrometheus(Счетчики, Префикс = "")

	Текст = Новый Массив();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		ЗаголовокСчетчика = СтрШаблон("%1%2", Префикс, СтрЗаменить(ТекСчетчик.Ключ, "-", "_"));

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];

		Текст.Добавить(СтрШаблон("# HELP %1 %2", ЗаголовокСчетчика, ОписаниеСчетчика));
		Текст.Добавить(СтрШаблон("# TYPE %1 gauge", ЗаголовокСчетчика));

		Для Каждого ТекЗначение Из ТекСчетчик.Значение["values"] Цикл

			ЗначенияИзмеренийСтрокой = "";
			ЗначениеСчетчика = Неопределено;
			Для Каждого ТекИзмерение Из ТекЗначение Цикл
				Если ВРег(ТекИзмерение.Ключ) = ВРег("_value") Тогда
					ЗначениеСчетчика = ТекИзмерение.Значение;
					Продолжить;
				КонецЕсли;

				ЗначениеИзмерения = ТекИзмерение.Значение;
				Если ТипЗнч(ЗначениеИзмерения) = Тип("Дата") Тогда
					ЗначениеИзмерения = Формат(ЗначениеИзмерения, "ДФ=yyyy-MM-ddThh:mm:ss");
				КонецЕсли;
				ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
				                           ?(ЗначенияИзмеренийСтрокой = "", "", ",") +
				                           СтрШаблон("%1=""%2""", СтрЗаменить(ТекИзмерение.Ключ, "-", "_"), ЗначениеИзмерения);
			КонецЦикла;

			Если НЕ ЗначениеЗаполнено(ЗначениеСчетчика) Тогда
				ЗначениеСчетчика = 0;
			КонецЕсли;
			Если ТипЗнч(ЗначениеСчетчика) = Тип("Число") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика, "ЧРД=.; ЧН=; ЧГ=0");
			ИначеЕсли ТипЗнч(ЗначениеСчетчика) = Тип("Дата") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика - Дата(1, 1, 1, 0, 0, 0), "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;
			Текст.Добавить(СтрШаблон("%1{%2} %3",
			                         ЗаголовокСчетчика,
			                         ЗначенияИзмеренийСтрокой,
			                         ЗначениеСчетчика));
		КонецЦикла;

		Текст.Добавить(" ");

	КонецЦикла;

	Возврат СтрСоединить(Текст, Символы.ПС);

КонецФункции // ФорматPrometheus()

// Функция - преобразует переданные значения счетчиков в плоский (Plain) текстовый формат
//
// Параметры:
//   Счетчики        - Соответствие     - счетчики для преобразования
//   Префикс         - Строка           - строковый префикс счетчиков,
//                                        который будет добавлен к именам счетчиков в результате
//   ТолькоЗначение  - Строка           - Истина - если передан только 1 счетчик с единственным значением,
//                                        будет возвращено только его значение без имени счетчика
//
// Возвращаемое значение:
//   Строка                 - значения счетчиков в плоском (Plain) текстовом формате
//
Функция ФорматPlain(Счетчики, Префикс = "", ТолькоЗначение = Ложь)

	Текст = Новый Массив();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		Для Каждого ТекЗначение Из ТекСчетчик.Значение["values"] Цикл
			
			ЗначенияИзмеренийСтрокой = "";
			ЗначениеСчетчика = Неопределено;
			Для Каждого ТекИзмерение Из ТекЗначение Цикл
				Если ВРег(ТекИзмерение.Ключ) = ВРег("_value") Тогда
					ЗначениеСчетчика = ТекИзмерение.Значение;
					Продолжить;
				КонецЕсли;

				ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
				                           ?(ЗначенияИзмеренийСтрокой = "", "", ",") +
				                           СтрШаблон("%1=""%2""", ТекИзмерение.Ключ, ТекИзмерение.Значение);
			КонецЦикла;

			Если НЕ ЗначениеЗаполнено(ЗначениеСчетчика) Тогда
				ЗначениеСчетчика = 0;
			КонецЕсли;
			
			Если ТипЗнч(ЗначениеСчетчика) = Тип("Число") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;

			Если ЗначениеЗаполнено(ЗначенияИзмеренийСтрокой) Тогда
				ЗначенияИзмеренийСтрокой = СтрШаблон("(%1)", ЗначенияИзмеренийСтрокой);
			КонецЕсли;

			Если ТолькоЗначение И Счетчики.Количество() = 1 И ТекСчетчик.Значение["values"].Количество() = 1 Тогда
				Текст.Добавить(ЗначениеСчетчика);
			Иначе
				Текст.Добавить(СтрШаблон("%1%2%3=%4",
				                         Префикс,
				                         ТекСчетчик.Ключ,
				                         ЗначенияИзмеренийСтрокой,
				                         ЗначениеСчетчика));
			КонецЕсли;
		КонецЦикла;

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
