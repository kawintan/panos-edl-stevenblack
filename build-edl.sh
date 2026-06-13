name: build-panos-edl
 
on:
  schedule:
    - cron: "30 4 * * *"   # runs daily at 04:30 UTC
  workflow_dispatch: {}     # lets you run it by hand from the Actions tab
 
permissions:
  contents: write
 
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build EDL
        run: |
          chmod +x build-edl.sh
          ./build-edl.sh
      - name: Commit if changed
        run: |
          git config user.name  "edl-bot"
          git config user.email "edl-bot@users.noreply.github.com"
          git add edl/panos-edl.txt
          git diff --staged --quiet || { git commit -m "Update EDL ($(date -u +%F))"; git push; }
