/// <reference types="node"/>

import { homedir } from 'os'
import * as path from 'path'
import * as fs from 'fs'

const minimist = require('minimist')

enum Action {
  search,
  add,
  last
}

class Lwd {
  private action: Action
  private param: string
  private file: string = path.join(homedir(), '.lwdhistory')
  private lwdList: string[] = []
  private maxSize: number = 100
  constructor(args: string[]) {
    if (args.length === 2) {
      this.action = args[0] === 'add' ? Action.add : Action.search
      this.param = args[1]
    } else {
      this.action = Action.last
    }
  }

  loadLwdHistory() {
    if (!fs.existsSync(this.file)) return this.lwdList
    const content: string = fs.readFileSync(this.file).toString()
    this.lwdList = JSON.parse(content)
    return this.lwdList
  }

  saveHisotry() {
    fs.writeFileSync(this.file, JSON.stringify(this.lwdList, null, 2))
  }

  add() {
    if (this.lwdList.indexOf(this.param) >= 0) {
      this.lwdList.splice(this.lwdList.indexOf(this.param), 1)
    }
    this.lwdList = [path.normalize(this.param)].concat(this.lwdList)
    if (this.lwdList.length > this.maxSize) {
      this.lwdList = this.lwdList.slice(0, this.maxSize)
    }
    return this
  }

  search() {
    const re = new RegExp(this.param)
    const cwd = new RegExp(`${process.cwd()}${path.sep}`, (/darwin/.test(process.platform) ? 'gi' : 'g'))

    this.lwdList.forEach((p) => {
      if(!re.test(p)) {
        return
      }
      process.stdout.write(`${p.replace(cwd, '').replace(process.cwd(), '.')}\n`)
    })
    return this
  }
  last() {
    if (this.lwdList.length === 0) return process.stdout.write(`${process.cwd()}`)
    process.stdout.write(`${this.lwdList[0]}\n`)
  }
  run() {
    this.loadLwdHistory()
    if (this.action === Action.add) {
      this.add().saveHisotry()
    } else if (this.action === Action.search) {
      this.search().saveHisotry()
    }
    else {
      this.last()
    }
  }
}

new Lwd(minimist(process.argv.slice(2))._).run()
