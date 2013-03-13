//
//  AppDelegate.m
//  Repl
//
//  Created by Mikhail Ivanov on 02.07.12.
//  Copyright (c) 2012 Ivanych. All rights reserved.
//

#import "AppDelegate.h"
#import "Three.h"
#import "List.h"


@implementation AppDelegate

// Инициализация приложения
- (void)awakeFromNib {
    // Объект статусной панели
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // Объект для работы с файлами
    NSBundle *bundle = [NSBundle mainBundle];
    
    // Загрузка изображений для иконки
    statusImage1 = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon1"
                                                                            ofType:@"png"
                                                                       inDirectory:@"icons"]];
    
    statusImage2 = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon2"
                                                                            ofType:@"png"
                                                                       inDirectory:@"icons"]];
    
    // Параметры объекта статусной панели
    [statusItem setMenu:statusMenu];
    [statusItem setImage:statusImage1];
    [statusItem setAlternateImage:statusImage2];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"Repl"];
    
    // Дерево меню
    three = [[Three alloc] init];
    
    // Связать дерево с меню
    [three setMenu:statusMenu];
    
    // Список треков
    trackList = [[List alloc] init];
    
    // Связать дерево со списком треков
    [three setList:trackList];
    
    // Плеер
    player =[[Player alloc] init];
    
    // Связать плеер со списком треков
    [player setList:trackList];
    
    // Связать плеер с деревом меню
    [player setMenu:three];
    
    // Связать список с деревом меню
    [trackList setMenu:three];
    
    // Конфиг
    config = [NSUserDefaults standardUserDefaults];

    // Восстановить список файлов из конфига
    NSString *files = [config objectForKey:@"files"];
    if (files) {
        NSLog(@"App.awakeFromNib - files: %@", files);
        
        [three openFile:files];
    }
    
    // Восстановить флаг случайного режима из конфига
    NSInteger rndFlag = [config integerForKey:@"rndFlag"];
    if (rndFlag) {
        NSLog(@"App.awakeFromNib - rndFlag: %ld", rndFlag);
        
        [trackList setRndFlag:rndFlag];
    }
}

// Открыть файлы
- (IBAction)openFile:(id)sender {
    NSLog(@"App.openFile --------------------------------");
    NSLog(@"App.openFile -> sender: %@, ", sender);
    
    // Создать диалог открытия файлов
    NSOpenPanel *fileDialog = [NSOpenPanel openPanel];
    
    // Свойства диалога
    [fileDialog setCanChooseFiles:YES];
    [fileDialog setCanChooseDirectories:YES];
    [fileDialog setAllowsMultipleSelection:YES];
    [fileDialog setAllowedFileTypes:[NSSound soundUnfilteredTypes]];
    
    // Вывести диалог
    // Если запуск вернул нажатие кнопки OK - обработать выбранные файлы
    if ( [fileDialog runModal] == NSFileHandlingPanelOKButton ) {
        
        // Список выбранных файлов (url)
        NSArray *urls = [fileDialog URLs];
        
        // Находим меню треков (тег "1" для пункта меню треков задан в редакторе, в файле интерфейса)
        NSMenuItem * trackMenuItem = [statusMenu itemWithTag:1];
        NSMenu * trackMenu = [trackMenuItem submenu];
        
        // Очищаем меню треков от предыдущего содержимого
        [trackMenu removeAllItems];
        
        // Останавливаем проигрывание
        [player stop];
        
        // Обнуляем проигрываемый трек
        [trackList setPlayTrack:0];
        
        // Очищаем список треков от предыдущего содержимого
        [trackList reset];
        
        // Переформатируем открытые URL в path
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:1];
        
        for(NSURL *url in urls) {
            NSLog(@"App.openFile - url: %@", url);
            
            // Берем из URL только путь к файлу
            NSString *path = [url path];
            NSLog(@"App.openFile - path: %@", path);
            
            [files addObject:path];
        }
        
        // Сохраняем список выбранных файлов в конфиг
        [config setObject:files forKey:@"files"];
        [config synchronize];
        
        // Открыть список файлов
        [three openFile:files];
    }
}

// Запустить трек
- (IBAction)playTrack:(id)sender {
    NSLog(@"App.playTrack --------------------------------");
    NSLog(@"App.playTrack -> sender: %@, ", sender);
    
    NSLog(@"App.playTrack - item tag: %ld, item title: %@", [sender tag], [sender title]);

    // Определить номер по тегу
    NSUInteger number = [sender tag] - 100;
    NSLog(@"App.playTrack - number: %ld", number);
    
    // Запустить проигрывание трека
    [player playTrack:number];
}

// Приостановить/продолжить трек
- (IBAction)pauseTrack:(id)sender {
    NSLog(@"App.pauseTrack --------------------------------");
    NSLog(@"App.pauseTrack -> sender: %@, ", sender);
    
    // Приостановить или продолжить трек
    [player pauseTrack];
}

// Следующий трек
- (IBAction)nextTrack:(id)sender {
    NSLog(@"App.nextTrack --------------------------------");
    NSLog(@"App.nextTrack -> sender: %@, ", sender);
    
    // Следующий трек
    [player playNextTrack];
}

// Предыдущий трек
- (IBAction)prevTrack:(id)sender {
    NSLog(@"App.prevTrack --------------------------------");
    NSLog(@"App.prevTrack -> sender: %@, ", sender);
    
    // Предыдущий трек
    [player playPrevTrack];
}

// Переключить флаг случайного режима воспроизведения
- (IBAction)turnRandom:(id)sender {
    NSLog(@"App.turnRandom --------------------------------");
    NSLog(@"App.turnRandom -> sender: %@, ", sender);
    
    [trackList turnRndFlag];
    
    // Сохраняем флаг случайного режима в конфиг
    [config setInteger:[trackList rndFlag] forKey:@"rndFlag"];
    [config synchronize];
}

@end
