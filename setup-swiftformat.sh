brew install swiftformat && \
npm install --global git-format-staged && \
echo '#!/bin/bash\ngit-format-staged --formatter "swiftformat stdin --stdinpath \x27{}\x27" "*.swift"' > '.git/hooks/pre-commit' && \
chmod +x .git/hooks/pre-commit && \
git config --global core.hooksPath '~/.githooks' 