﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура Номенклатура_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	Если НЕ Параметры.Свойство("ПараметрыКорзины") Тогда
		Возврат;
	КонецЕсли;
	
	Если Параметры.Свойство("Склад") Тогда
		Объект.Склад = Параметры.Склад;
		Объект.Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Склад, "Организация");
	КонецЕсли;
	
	ПараметрыКорзины = Параметры.ПараметрыКорзины;
	Если ПараметрыКорзины.Свойство("АдресКорзиныВХранилище") И ЗначениеЗаполнено(ПараметрыКорзины.АдресКорзиныВХранилище) Тогда
		ТаблицаДляЗагрузки = ПолучитьИзВременногоХранилища(ПараметрыКорзины.АдресКорзиныВХранилище);
		Объект.Товары.Загрузить(ТаблицаДляЗагрузки);
		ПерезаполнитьРеквизитыТовары = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура_ПриОткрытииПосле(Отказ)
	
	Если ПерезаполнитьРеквизитыТовары Тогда
		ПересчитатьТоварыИзКорзиныНаКлиенте();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура_ПередЗакрытиемПосле(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Оповестить("ЗакрытДокумент", Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура_ОбработкаОповещенияПосле(ИмяСобытия, Параметр, Источник)
	
	Если Источник = ЭтотОбъект Тогда
		Возврат;
	КонецЕсли;
	
	Если ИмяСобытия = "ДополнитьТовары" И Параметры.КлючНазначенияИспользования = "Корзина" Тогда
		Если Параметр.Свойство("ИмяДокумента") И Параметр.ИмяДокумента = "ЗаказПоставщику" Тогда
			ДополнитьТоварыНаСервере(Параметр.АдресКорзиныВХранилище);
			ПересчитатьТоварыИзКорзиныНаКлиенте();
			ЭтотОбъект.Активизировать();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПересчитатьТоварыИзКорзиныНаКлиенте()
	
	Для Каждого ТекущаяСтрока Из Объект.Товары Цикл
		ТекущаяСтрока.КоличествоУпаковок = ТекущаяСтрока.Количество;
		Номенклатура_ПриИзмененииНоменклатуры(ТекущаяСтрока);
	КонецЦикла;
	
	ОбновитьИтоговыеПоказатели();
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ДополнитьТоварыНаСервере(АдресКорзиныВХранилище)
	
	ИсходнаяТаблица = Объект.Товары.Выгрузить();
	ТаблицаДляЗагрузки = ПолучитьИзВременногоХранилища(АдресКорзиныВХранилище);
	ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(ТаблицаДляЗагрузки, ИсходнаяТаблица);
	Объект.Товары.Загрузить(ИсходнаяТаблица);
	
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура_ПриИзмененииНоменклатуры(ТекущаяСтрока)
	
	СтруктураДействий = Новый Структура;
	СтруктураДействий.Вставить("ЗаполнитьТипНоменклатуры");
	СтруктураДействий.Вставить("ПроверитьХарактеристикуПоВладельцу", ТекущаяСтрока.Характеристика);
	СтруктураДействий.Вставить("ПроверитьЗаполнитьУпаковкуПоВладельцу"      , ТекущаяСтрока.Упаковка);
	СтруктураДействий.Вставить("ПересчитатьКоличествоЕдиниц");
	СтруктураДействий.Вставить("ЗаполнитьЦенуЗакупки",
		ОбработкаТабличнойЧастиТоварыКлиент.СтруктураЗаполненияЦеныЗакупкиВСтрокеТЧ(Объект));
	
	СтруктураДействий.Вставить("ЗаполнитьСтавкуНДС", ОбработкаТабличнойЧастиТоварыКлиентСервер.СтруктураПараметровСтавкиНДСУчитыватьНДС(Объект));
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС",
		ОбработкаТабличнойЧастиТоварыКлиент.СтруктураПересчетаСуммыНДСВСтрокеТЧ(Объект));
	
	СтруктураДействий.Вставить("ПересчитатьСумму");
	Если ИспользоватьАссортимент Тогда
		СтруктураПроверкиАссортимента = АссортиментКлиентСервер.ПараметрыПроверкиАссортимента(Объект);
		СтруктураПроверкиАссортимента.Дата = ?(ЗначениеЗаполнено(Объект.ДатаПоступления),
			Объект.ДатаПоступления,
			Объект.Дата);
		СтруктураПроверкиАссортимента.ТекстСообщения =
			НСтр("ru = 'Номенклатура ""%1"" не включена в ассортимент магазина или запрещена к закупке. Заказывать ее не рекомендуется.'");
		СтруктураДействий.Вставить("ПроверитьАссортиментСтроки", СтруктураПроверкиАссортимента);
	КонецЕсли;
	
	Если ИспользоватьЭДО Тогда
		СтруктураДействий.Вставить("ЗаполнитьИдентификаторНоменклатурыПоставщика", Новый Структура("Контрагент", Объект.Контрагент));
	КонецЕсли;
	
	ОбработкаТабличнойЧастиТоварыКлиент.ПриИзмененииРеквизитовВТЧКлиент(
		Объект.Товары,
		ТекущаяСтрока,
		СтруктураДействий,
		КэшированныеЗначения);
	
	ОбработкаТабличнойЧастиТоварыКлиентСервер.ЗаполнитьСуммуВсегоВСтрокеТаблицы(ТекущаяСтрока, Объект.ЦенаВключаетНДС);
	ОбработкаТабличнойЧастиТоварыКлиентСервер.ОбновитьСуммыПодвала(Объект.Товары, Объект.ЦенаВключаетНДС, СуммаВсего);
	
КонецПроцедуры

#КонецОбласти