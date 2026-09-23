import re

from app.api.schemas import MemoryCandidate


class HeuristicMemoryExtractor:
    """Conservative MVP extractor.

    It intentionally stores only explicit, stable statements. A future LLM extractor
    must preserve this output contract and keep the same confidence threshold.
    """

    _goal_pattern = re.compile(r"(?:我想|我要|目标是)(?:学习)?(.{2,80})")
    _time_pattern = re.compile(r"(?:每天|每日)(.{1,20}?)(?:分钟|小时)")
    _preference_pattern = re.compile(r"(?:我喜欢|我更喜欢|请)(.{2,80})")

    def extract(self, text: str) -> list[MemoryCandidate]:
        candidates: list[MemoryCandidate] = []
        if match := self._goal_pattern.search(text):
            candidates.append(
                MemoryCandidate(
                    category="learning",
                    content=f"用户的学习目标是：{match.group(1).strip()}",
                    confidence=0.82,
                    importance=4,
                )
            )
        if match := self._time_pattern.search(text):
            candidates.append(
                MemoryCandidate(
                    category="constraint",
                    content=f"用户每日可用学习时间约为：{match.group(1).strip()}分钟或小时",
                    confidence=0.8,
                    importance=4,
                )
            )
        if match := self._preference_pattern.search(text):
            candidates.append(
                MemoryCandidate(
                    category="preference",
                    content=f"用户偏好：{match.group(1).strip()}",
                    confidence=0.76,
                    importance=3,
                )
            )
        return candidates

