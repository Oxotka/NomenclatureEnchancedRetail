﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура Номенклатура_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	Если НЕ Параметры.Свойство("ПараметрыКорзины") Тогда
		Возврат;
	КонецЕсли;
	
	Если Параметры.Свойство("Склад") Тогда
		Объект.Склад = Параметры.Склад;
		Объект.Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Склад, "Организация");	
		ОбщегоНазначенияРТКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы,"БанковскийСчетОрганизации", "ТолькоПросмотр",
																	НЕ ЗначениеЗаполнено(Объект.Организация));
	
		Объект.БанковскийСчетОрганизации = ЗначениеНастроекВызовСервера.БанковскийСчетОрганизацииПоУмолчанию(
			Объект.Организация,
			,
			Объект.БанковскийСчетОрганизации);
		
		ПересчетНДСТабличнойЧастиСервер();
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

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПересчитатьТоварыИзКорзиныНаКлиенте()
	
	Для Каждого ТекущаяСтрока Из Объект.Товары Цикл
		ТекущаяСтрока.КоличествоУпаковок = ТекущаяСтрока.Количество;
		Номенклатура_ПриИзмененииНоменклатуры(ТекущаяСтрока);
	КонецЦикла;
	
	ОбновитьИтоговыеПоказатели();
	ПересчитатьИлиОтменитьСкидки();
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура Номенклатура_ПриИзмененииНоменклатуры(ТекущаяСтрока)
	
	СтруктураДействий = Новый Структура;
	СтруктураДействий.Вставить("ЗаполнитьТипНоменклатуры");
	СтруктураДействий.Вставить("ПроверитьФлагРезервирования");
	СтруктураДействий.Вставить("ПроверитьХарактеристикуПоВладельцу"   , ТекущаяСтрока.Характеристика);
	СтруктураДействий.Вставить("ПроверитьЗаполнитьУпаковкуПоВладельцу", ТекущаяСтрока.Упаковка);
	СтруктураДействий.Вставить("ПересчитатьКоличествоЕдиниц");
	СтруктураДействий.Вставить("ЗаполнитьЦенуПродажи" , 
								ОбработкаТабличнойЧастиТоварыКлиент.СтруктураЗаполненияЦеныПродажиВСтрокеТЧ(Объект, Истина));
	СтруктураДействий.Вставить("ЗаполнитьСтавкуНДССкладВШапке", 
								ОбработкаТабличнойЧастиТоварыКлиентСервер.СтруктураПараметровСтавкиНДССкладВидНалогаВШапке(Объект));
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС", 
								ОбработкаТабличнойЧастиТоварыКлиент.СтруктураПересчетаСуммыНДСВСтрокеТЧ(Объект));
	СтруктураДействий.Вставить("ПересчитатьСумму");
	СтруктураДействий.Вставить("ПроставитьПродавца", Объект.Продавец);
	СтруктураДействий.Вставить("ПересчитатьСуммуСУчетомРучнойСкидки", Новый Структура("Очищать", Истина));
	СтруктураДействий.Вставить("ПересчитатьСуммуСУчетомАвтоматическойСкидки", Новый Структура("Очищать", Истина));
	
	Если ИспользоватьАссортимент Тогда
		СтруктураДействий.Вставить("ПроверитьАссортиментСтроки", АссортиментКлиентСервер.ПараметрыПроверкиАссортимента(Объект, Истина));
	КонецЕсли;
	
	ОбработкаТабличнойЧастиТоварыКлиент.ПриИзмененииРеквизитовВТЧКлиент(Объект.Товары, ТекущаяСтрока, СтруктураДействий, КэшированныеЗначения);
	
	ОбработкаТабличнойЧастиТоварыКлиентСервер.ЗаполнитьСуммуВсегоВСтрокеТаблицы(ТекущаяСтрока, Объект.ЦенаВключаетНДС);
	ОбработкаТабличнойЧастиТоварыКлиентСервер.ЗаполнитьКлючСвязи(Объект.Товары, ТекущаяСтрока, "КлючСвязи");
	
	Если ПропуститьАвтоматическийРасчетСкидок Тогда
		ПропуститьАвтоматическийРасчетСкидок = Ложь;
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
		Если Параметр.Свойство("ИмяДокумента") И Параметр.ИмяДокумента = "ЗаказПокупателя" Тогда
			ДополнитьТоварыНаСервере(Параметр.АдресКорзиныВХранилище);
			ПересчитатьТоварыИзКорзиныНаКлиенте();
			ЭтотОбъект.Активизировать();
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ДополнитьТоварыНаСервере(АдресКорзиныВХранилище)
	
	ИсходнаяТаблица = Объект.Товары.Выгрузить();
	ТаблицаДляЗагрузки = ПолучитьИзВременногоХранилища(АдресКорзиныВХранилище);
	ОбщегоНазначенияКлиентСервер.ДополнитьТаблицу(ТаблицаДляЗагрузки, ИсходнаяТаблица);
	Объект.Товары.Загрузить(ИсходнаяТаблица);
	
КонецПроцедуры

#КонецОбласти