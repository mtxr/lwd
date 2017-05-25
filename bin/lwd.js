"use strict";
/// <reference types="node"/>
Object.defineProperty(exports, "__esModule", { value: true });
var os_1 = require("os");
var path = require("path");
var fs = require("fs");
var minimist = require('minimist');
var Action;
(function (Action) {
    Action[Action["search"] = 0] = "search";
    Action[Action["add"] = 1] = "add";
    Action[Action["last"] = 2] = "last";
})(Action || (Action = {}));
var Lwd = (function () {
    function Lwd(args) {
        this.file = path.join(os_1.homedir(), '.lwdhistory');
        this.lwdList = [];
        this.maxSize = 100;
        if (args.length === 2) {
            this.action = args[0] === 'add' ? Action.add : Action.search;
            this.param = args[1];
        }
        else {
            this.action = Action.last;
        }
    }
    Lwd.prototype.loadLwdHistory = function () {
        if (!fs.existsSync(this.file))
            return this.lwdList;
        var content = fs.readFileSync(this.file).toString();
        this.lwdList = JSON.parse(content);
        return this.lwdList;
    };
    Lwd.prototype.saveHisotry = function () {
        fs.writeFileSync(this.file, JSON.stringify(this.lwdList, null, 2));
    };
    Lwd.prototype.add = function () {
        if (this.lwdList.indexOf(this.param) >= 0) {
            this.lwdList.splice(this.lwdList.indexOf(this.param), 1);
        }
        this.lwdList = [path.normalize(this.param)].concat(this.lwdList);
        if (this.lwdList.length > this.maxSize) {
            this.lwdList = this.lwdList.slice(0, this.maxSize);
        }
        return this;
    };
    Lwd.prototype.search = function () {
        var re = new RegExp(this.param);
        var cwd = new RegExp("" + process.cwd() + path.sep, (/darwin/.test(process.platform) ? 'gi' : 'g'));
        this.lwdList.forEach(function (p) {
            if (!re.test(p)) {
                return;
            }
            process.stdout.write(p.replace(cwd, '').replace(process.cwd(), '.') + "\n");
        });
        return this;
    };
    Lwd.prototype.last = function () {
        if (this.lwdList.length === 0)
            return process.stdout.write("" + process.cwd());
        process.stdout.write(this.lwdList[0] + "\n");
    };
    Lwd.prototype.run = function () {
        this.loadLwdHistory();
        if (this.action === Action.add) {
            this.add().saveHisotry();
        }
        else if (this.action === Action.search) {
            this.search().saveHisotry();
        }
        else {
            this.last();
        }
    };
    return Lwd;
}());
new Lwd(minimist(process.argv.slice(2))._).run();
