DM = require "./dm_nodes"
VL = require "../vl_nodes"

exports.metrics =
  length:     new DM.Metric "length", "px",
                cm: new VL.Number 96/2.54
                mm: new VL.Number 96/25.4
                in: new VL.Number 96
                pt: new VL.Number 96/72
                pc: new VL.Number 96/72/12
  time:       new DM.Metric "time", "ms",
                s: new VL.Number 1000
                #m: new VL.Number 1000*60
                #h: new VL.Number 1000*60*60
                #d: new VL.Number 1000*60*60*24
                #y: new VL.Number 1000*60*60*24*365.24
  angle:      new DM.Metric "angle", "rad",
                deg: new VL.Number Math.PI/180
                grad: new VL.Number Math.PI/200
                turn: new VL.Number 2*Math.PI
  frequency:  new DM.Metric "frequency", "hz",
                khz: new VL.Number 1000
  resolution: new DM.Metric "resolution", "dppx",
                dpi: new VL.Number 1/96
                dpcm: new VL.Number 1/96*2.54

