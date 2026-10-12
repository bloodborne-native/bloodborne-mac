// Choices of the settings pages; labels and hints are i18n keys.
import type { Option, TKey } from "@/lib/types";

export const UPSCALERS: Option<string>[] = [
  { value: "fsr411", label: "options.upscaler.fsr411", hint: "options.upscaler.fsr411Hint" },
  { value: "fsr4", label: "options.upscaler.fsr4", hint: "options.upscaler.fsr4Hint" },
  { value: "fsr3", label: "options.upscaler.fsr3", hint: "options.upscaler.fsr3Hint" },
  { value: "off", label: "options.upscaler.off", hint: "options.upscaler.offHint" },
];

export const PRESETS: { value: number; label: TKey; scale: number }[] = [
  { value: 0, label: "options.preset.0", scale: 1.0 },
  { value: 1, label: "options.preset.1", scale: 1.5 },
  { value: 2, label: "options.preset.2", scale: 1.7 },
  { value: 3, label: "options.preset.3", scale: 2.0 },
  { value: 4, label: "options.preset.4", scale: 3.0 },
];

export const OUTPUT_RES: Option<string>[] = [
  { value: "1280x720", label: "1280 × 720", literal: true },
  { value: "1920x1080", label: "1920 × 1080", literal: true },
  { value: "2560x1440", label: "2560 × 1440", literal: true },
  { value: "3840x2160", label: "3840 × 2160", literal: true },
];

/** The scene size an output and preset render at (scripts/patches.py: even sizes). */
export function renderSize(output: string, preset: number, upscaler: string): string {
  const [w, h] = output.split("x").map(Number);
  const scale = upscaler === "off" ? 1 : (PRESETS.find((p) => p.value === preset)?.scale ?? 1);
  const even = (v: number) => Math.max(2, Math.round(v / scale / 2) * 2);
  return `${even(w || 1920)} × ${even(h || 1080)}`;
}

/** bbport.ini effect switches (patches at start); all on by default except SSR. */
export const EFFECTS: { key: string; label: TKey; hint?: TKey; defaultOn: boolean }[] = [
  { key: "effect_chromatic_aberration", label: "options.effects.effect_chromatic_aberration", defaultOn: true },
  { key: "effect_dof", label: "options.effects.effect_dof", defaultOn: true },
  { key: "effect_motion_blur", label: "options.effects.effect_motion_blur", defaultOn: true },
  { key: "effect_ssao", label: "options.effects.effect_ssao", defaultOn: true },
  { key: "effect_game_aa", label: "options.effects.effect_game_aa", defaultOn: true },
  { key: "effect_dynamic_shadows", label: "options.effects.effect_dynamic_shadows", defaultOn: true },
  { key: "effect_ssr", label: "options.effects.effect_ssr", hint: "options.effects.effect_ssrHint", defaultOn: false },
];

/** The PS4 system language the game sees (BB_LANGUAGE, SCE language codes): names in their own
 *  language. Every one has its text in the game (dvdroot_ps4/msg). */
export const GAME_LANGUAGES: Option<string>[] = [
  { value: "1", label: "English (US)", literal: true },
  { value: "18", label: "English (UK)", literal: true },
  { value: "17", label: "Português (Brasil)", literal: true },
  { value: "7", label: "Português (Portugal)", literal: true },
  { value: "3", label: "Español (España)", literal: true },
  { value: "20", label: "Español (Latinoamérica)", literal: true },
  { value: "2", label: "Français", literal: true },
  { value: "4", label: "Deutsch", literal: true },
  { value: "5", label: "Italiano", literal: true },
  { value: "6", label: "Nederlands", literal: true },
  { value: "16", label: "Polski", literal: true },
  { value: "8", label: "Русский", literal: true },
  { value: "19", label: "Türkçe", literal: true },
  { value: "12", label: "Suomi", literal: true },
  { value: "13", label: "Svenska", literal: true },
  { value: "14", label: "Dansk", literal: true },
  { value: "15", label: "Norsk", literal: true },
  { value: "0", label: "日本語", literal: true },
  { value: "9", label: "한국어", literal: true },
  { value: "11", label: "简体中文", literal: true },
  { value: "10", label: "繁體中文", literal: true },
];

export const FPS_MODES: Option<string>[] = [
  { value: "uncap", label: "options.fps.uncap", hint: "options.fps.uncapHint" },
  { value: "60", label: "options.fps.60" },
  { value: "90", label: "options.fps.90" },
  { value: "30", label: "options.fps.30", hint: "options.fps.30Hint" },
];

export const MODEL_LOD: Option<string>[] = [
  { value: "-2", label: "options.lod.-2" },
  { value: "0", label: "options.lod.0" },
  { value: "1", label: "options.lod.1" },
  { value: "2", label: "options.lod.2" },
];

export const PRESENT_MODES: Option<string>[] = [
  { value: "Fifo", label: "options.present.Fifo" },
  { value: "FifoRelaxed", label: "options.present.FifoRelaxed" },
  { value: "Mailbox", label: "options.present.Mailbox" },
  { value: "Immediate", label: "options.present.Immediate" },
];

export const DRAW_PIPE: Option<string>[] = [
  { value: "", label: "options.drawPipe.auto", hint: "options.drawPipe.autoHint" },
  { value: "1", label: "options.drawPipe.on" },
  { value: "0", label: "options.drawPipe.off", hint: "options.drawPipe.offHint" },
];

export const READBACKS: Option<string>[] = [
  { value: "", label: "options.readbacks.relaxed" },
  { value: "2", label: "options.readbacks.precise" },
  { value: "0", label: "options.readbacks.off" },
];

export const PREUPLOAD: Option<string>[] = [
  { value: "", label: "options.preupload.normal" },
  { value: "2", label: "options.preupload.full", hint: "options.preupload.fullHint" },
  { value: "0", label: "options.preupload.off" },
];

export const LIVE_RESOLUTION: Option<string>[] = [
  { value: "0", label: "options.live.0" },
  { value: "1", label: "options.live.1" },
  { value: "auto", label: "options.live.auto" },
];
