# 3d-print

3D 프린터로 출력할 모델을 OpenSCAD 코드로 만드는 작업 공간입니다.

## 구성

```
3d-print/
├── models/
│   └── <모델 이름>/
│       ├── <모델 이름>.scad   소스 (치수는 파일 맨 위 변수)
│       ├── out/               내보낸 STL, 3MF, 미리보기 PNG
│       └── photos/            실제 출력물 사진
└── scripts/
    └── export.sh              내보내기 스크립트
```

## 내보내기

```sh
scripts/export.sh skadis-hair-dryer-holder
```

`models/<모델 이름>/out/`에 `<이름>.stl`, `<이름>.mesh.3mf`(형상만 담은 3MF), `<이름>.png`가 생깁니다. `<이름>.3mf`는 Bambu Studio에서 저장한 프로젝트(프린터, 서포트 설정 포함)이고 스크립트가 건드리지 않습니다. 치수를 바꿔서 내보내려면 `-D`를 붙입니다.

```sh
scripts/export.sh skadis-hair-dryer-holder -D hook_depth=5.2
```

OpenSCAD는 `/Applications/OpenSCAD.app`에 있는 것을 씁니다. 다른 위치에 있으면 `OPENSCAD` 환경변수로 실행 파일 경로를 지정합니다.

## 새 모델 추가

1. `models/<모델 이름>/<모델 이름>.scad`를 만듭니다. 폴더 이름과 파일 이름이 같아야 스크립트가 찾습니다.
2. 치수는 파일 맨 위에 변수로 모읍니다. 단위는 mm입니다.
3. `scripts/export.sh <모델 이름>`으로 내보내고, 출력에 `Status: NoError`가 나오는지 확인합니다.

## 모델 목록

| 모델 | 설명 | MakerWorld |
|---|---|---|
| [skadis-hair-dryer-holder](models/skadis-hair-dryer-holder/) | IKEA SKÅDIS 타공판용 헤어드라이어 거치대 | [3682340](https://makerworld.com/ko/models/3682340-ikea-skadis-hair-dryer-holder-with-cord-hook) |
| [ikea-eilif-screen-connector](models/ikea-eilif-screen-connector/) | IKEA EILIF 스크린 커넥터 | [2495648](https://makerworld.com/ko/models/2495648-ikea-eilif-screen-connector) |

## 라이선스

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). 출처를 밝히면 수정과 재배포를 할 수 있고, 상업적 이용은 할 수 없습니다.
