//
//  Created by David Dombrowe on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import os.log

/// Enthält statische Logs für verschiedene Kategorien
struct Logger {
    static let cad = OSLog(subsystem: "com.zeiss-izm.piwebmeshmodel", category: "cad")
}
